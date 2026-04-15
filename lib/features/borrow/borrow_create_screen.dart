import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/borrow_policy.dart';
import '../../core/l10n/book_category_display.dart';
import '../../core/utils/book_cover_display.dart';
import '../../core/utils/library_qr_payload.dart';
import '../../services/library_config_service.dart';
import '../shared/qr_scanner_screen.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình tạo phiếu mượn — **admin** và **manager** (nhân sự) tạo phiếu cho sinh viên; Firestore cũng cho phép sinh viên tự tạo phiếu cho chính mình nếu có luồng đó.
class BorrowCreateScreen extends StatefulWidget {
  const BorrowCreateScreen({super.key});

  @override
  State<BorrowCreateScreen> createState() => _BorrowCreateScreenState();
}

class _BorrowCreateScreenState extends State<BorrowCreateScreen> {
  final _bookCodeController = TextEditingController();
  final _userQueryController = TextEditingController();

  bool _routeArgsLoaded = false;

  /// Tra cứu sách / SV có thể chồng lịch (quét SV khi tra sách còn pending). Dùng seq để bỏ kết quả cũ, tránh ghi đè hoặc `_book = null` nhầm.
  int _bookLookupSeq = 0;
  int _userLookupSeq = 0;

  bool _busyBook = false;
  bool _busyUser = false;
  bool _busySubmit = false;

  _BookPreview? _book;
  _UserPreview? _user;

  /// Hạn trả (phần ngày). Mặc định: hôm nay + [BorrowPolicy.defaultLoanDays]; gợi ý từ `library_settings/config.loanDays` (clamp 7–14).
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _dueDate = DateTime(n.year, n.month, n.day).add(Duration(days: BorrowPolicy.defaultLoanDays));
    _loadLoanDays();
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _dueAtEndOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

  Future<void> _loadLoanDays() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('library_settings').doc('config').get();
      final data = doc.data();
      final loanDays = data?['loanDays'];
      if (loanDays is int && loanDays > 0 && mounted) {
        final x = DateTime.now();
        final d = BorrowPolicy.clampConfigToSuggestedRange(loanDays);
        setState(() {
          _dueDate = DateTime(x.year, x.month, x.day).add(Duration(days: d));
        });
      }
    } catch (_) {
      // Giữ mặc định đã khởi tạo trong initState
    }
  }

  Future<void> _pickDueDate() async {
    final t = AppLocalizations.of(context)!;
    final today = _dateOnly(DateTime.now());
    final first = today.add(Duration(days: BorrowPolicy.minLoanDays));
    final last = today.add(Duration(days: BorrowPolicy.maxLoanDays));
    var initial = _dateOnly(_dueDate);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: t.borrowDueDateTitle,
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = _dateOnly(picked));
    }
  }

  @override
  void dispose() {
    _bookCodeController.dispose();
    _userQueryController.dispose();
    super.dispose();
  }

  int _readInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  /// Tránh wedge/bàn phím ảo đưa kết quả quét vào [TextField] đang focus (thường làm ô sách bị ghi đè bằng LIB_USER...).
  void _unfocusBeforeQrScan() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Khôi phục ô mã sách + preview nếu bị ghi đè bởi mã SV (sau khi quét / tra SV).
  void _repairBookFieldAfterUserFlow(String bookBefore, _BookPreview? previewBefore, String rawScanned) {
    if (!mounted) return;
    final before = bookBefore.trim();
    if (before.isEmpty) return;
    final cur = _bookCodeController.text.trim();
    if (cur == before) return;

    final uq = _userQueryController.text.trim();
    final r = rawScanned.trim();

    final looksLikeScanLeak = cur == uq ||
        (r.isNotEmpty && cur == r) ||
        cur.startsWith(LibraryQrPayload.userPrefix) ||
        cur.startsWith(LibraryQrPayload.returnPrefix);

    if (!looksLikeScanLeak) return;

    _bookCodeController.text = bookBefore;
    if (previewBefore != null && (_book == null || _book!.id != previewBefore.id)) {
      setState(() => _book = previewBefore);
    }
  }

  Future<void> _scanBookQr() async {
    _unfocusBeforeQrScan();
    final t = AppLocalizations.of(context)!;
    final value = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(
        builder: (_) => QrScannerScreen(
          title: t.borrowScanBookTitle,
          hint: t.borrowScanBookHint,
        ),
      ),
    );
    if (value == null || value.trim().isEmpty) return;
    await _applyScannedBookPayload(value.trim());
  }

  Future<void> _scanUserQr() async {
    _unfocusBeforeQrScan();
    final t = AppLocalizations.of(context)!;
    final value = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(
        builder: (_) => QrScannerScreen(
          title: t.borrowScanStudentTitle,
          hint: t.borrowScanStudentHint,
        ),
      ),
    );
    if (value == null || value.trim().isEmpty) return;
    await _applyScannedUserPayload(value.trim());
  }

  Future<void> _applyScannedBookPayload(String raw) async {
    final t = AppLocalizations.of(context)!;
    final p = LibraryQrParseResult.parse(raw);
    if (p.borrowRecordId != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.borrowScannedReturnTicketHelp)),
      );
      return;
    }
    if (p.userId != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.borrowScannedStudentCodeHelp)),
      );
      return;
    }
    final key = p.bookLookupKey.trim();
    if (key.isEmpty) return;
    _bookCodeController.text = key;
    await _lookupBook();
  }

  Future<void> _applyScannedUserPayload(String raw) async {
    final t = AppLocalizations.of(context)!;
    final bookBefore = _bookCodeController.text;
    final previewBefore = _book;
    try {
      final p = LibraryQrParseResult.parse(raw);
      if (p.borrowRecordId != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.borrowScannedBorrowTicketNotForStudent)),
        );
        return;
      }
      final uid = p.userId?.trim();
      if (uid != null && uid.isNotEmpty) {
        _userQueryController.text = uid;
        await _lookupUser();
        return;
      }
      final key = p.bookLookupKey.trim();
      if (key.isEmpty) return;
      _userQueryController.text = key;
      await _lookupUser();
    } finally {
      if (mounted) {
        _repairBookFieldAfterUserFlow(bookBefore, previewBefore, raw);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeArgsLoaded) return;
    _routeArgsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : null;
    final bookId = map?['bookId']?.toString();
    final userIdArg = map?['userId']?.toString();
    if (bookId != null && bookId.isNotEmpty) {
      _bookCodeController.text = bookId;
    }
    if (userIdArg != null && userIdArg.isNotEmpty) {
      _userQueryController.text = userIdArg;
    }
    if ((bookId != null && bookId.isNotEmpty) || (userIdArg != null && userIdArg.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (bookId != null && bookId.isNotEmpty) await _lookupBook();
        if (!mounted) return;
        if (userIdArg != null && userIdArg.isNotEmpty) await _lookupUser();
      });
    }
  }

  InputDecoration _inputDec(ThemeData theme, {required String hint, IconData? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix != null ? Icon(prefix, size: 20) : null,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(t.borrowCreateTitle),
      ),
      // LayoutBuilder: chiều ngang từ constraint Scaffold (ổn định sau pop từ QrScanner). Không dùng Row+Expanded — tránh infinite width / sliver child.hasSize.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final raw = constraints.maxWidth;
          final mqW = MediaQuery.sizeOf(context).width;
          final safeW = (raw.isFinite && raw > 0) ? raw : ((mqW.isFinite && mqW > 0) ? mqW : 360.0);
          final contentW = (safeW - 32).clamp(120.0, 10000.0);
          final qrHalf = ((contentW - 10) / 2).clamp(48.0, 5000.0);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (AppUser.isStaff)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    AppUser.isAdmin ? t.borrowSignedInAsAdmin : t.borrowSignedInAsManager,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                t.borrowCreateFlowHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              _BorrowFlowSteps(
                bookOk: _book != null,
                userOk: _user != null,
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      width: qrHalf,
                      child: OutlinedButton.icon(
                        onPressed: (_busyBook || _busySubmit) ? null : _scanBookQr,
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: Text(t.scanBookQrButton),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: qrHalf,
                      child: OutlinedButton.icon(
                        onPressed: (_busyUser || _busySubmit) ? null : _scanUserQr,
                        icon: const Icon(Icons.badge_outlined, size: 20),
                        label: Text(t.scanStudentQrButton),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(t.bookCodeInputTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _bookCodeController,
                decoration: _inputDec(theme, hint: t.bookCodeHint, prefix: Icons.tag).copyWith(
                  suffixIcon: kIsWeb
                      ? null
                      : IconButton(
                          tooltip: t.scanBookQrButton,
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: (_busyBook || _busySubmit)
                              ? null
                              : () async {
                                  _unfocusBeforeQrScan();
                                  final value = await Navigator.push<String?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QrScannerScreen(
                                        title: t.scanBookTitle,
                                        hint: t.scanBookHint,
                                      ),
                                    ),
                                  );
                                  if (value == null || value.trim().isEmpty) return;
                                  await _applyScannedBookPayload(value.trim());
                                },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: (_busyBook || _busySubmit) ? null : _lookupBook,
                  child: Text(t.findAction),
                ),
              ),
              const SizedBox(height: 12),
              if (_book != null) SizedBox(width: contentW, child: _BookCard(book: _book!)),
              const SizedBox(height: 24),
              Text(t.studentBorrowerTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _userQueryController,
                decoration: _inputDec(theme, hint: t.studentBorrowerHint, prefix: Icons.person_outline).copyWith(
                  suffixIcon: kIsWeb
                      ? null
                      : IconButton(
                          tooltip: t.borrowScanStudentTooltip,
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: (_busyUser || _busySubmit)
                              ? null
                              : () async {
                                  _unfocusBeforeQrScan();
                                  final tt = AppLocalizations.of(context)!;
                                  final value = await Navigator.push<String?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QrScannerScreen(
                                        title: tt.borrowScanStudentTitle,
                                        hint: tt.borrowScanStudentInlineHint,
                                      ),
                                    ),
                                  );
                                  if (value == null || value.trim().isEmpty) return;
                                  await _applyScannedUserPayload(value.trim());
                                },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: (_busyUser || _busySubmit) ? null : _lookupUser,
                  child: Text(t.findAction),
                ),
              ),
              const SizedBox(height: 12),
              if (_user != null) SizedBox(width: contentW, child: _UserCard(user: _user!)),
              const SizedBox(height: 24),
              Text(t.borrowDateLabel, style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              _ReadonlyField(value: _formatDate(now), width: contentW),
              const SizedBox(height: 12),
              Text(t.borrowDueDateTitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                t.borrowDueDateHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              _DueDatePickerTile(
                width: contentW,
                valueText: _formatDate(_dueDate),
                enabled: !_busySubmit,
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: contentW,
                child: ElevatedButton(
                  onPressed: (_busySubmit || _busyBook || _busyUser || _book == null || _user == null)
                      ? null
                      : _createBorrowRecord,
                  child: _busySubmit
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : Text(t.createBorrowButton),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _lookupBook() async {
    final t = AppLocalizations.of(context)!;
    final code = _bookCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pleaseEnterBookCode)));
      return;
    }

    final seq = ++_bookLookupSeq;
    if (!mounted) return;
    setState(() => _busyBook = true);
    try {
      final booksRef = FirebaseFirestore.instance.collection('books');

      // Ưu tiên thử theo document id trước
      final byId = await booksRef.doc(code).get();
      if (!mounted || seq != _bookLookupSeq) return;
      if (byId.exists) {
        final data = byId.data();
        if (data != null) {
          setState(() => _book = _BookPreview.fromDoc(byId.id, data));
        }
        return;
      }

      // Nếu không phải id thì thử theo ISBN
      final byIsbn = await booksRef.where('isbn', isEqualTo: code).limit(1).get();
      if (!mounted || seq != _bookLookupSeq) return;
      if (byIsbn.docs.isNotEmpty) {
        final doc = byIsbn.docs.first;
        setState(() => _book = _BookPreview.fromDoc(doc.id, doc.data()));
        return;
      }

      if (!mounted || seq != _bookLookupSeq) return;
      setState(() => _book = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.bookNotFoundShort)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.bookLookupError('$e'))));
      }
    } finally {
      if (mounted && seq == _bookLookupSeq) {
        setState(() => _busyBook = false);
      }
    }
  }

  Future<void> _lookupUser() async {
    final t = AppLocalizations.of(context)!;
    final bookBefore = _bookCodeController.text;
    final previewBefore = _book;

    final q = _userQueryController.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pleaseEnterStudentQuery)));
      return;
    }

    final seq = ++_userLookupSeq;
    if (!mounted) return;
    setState(() => _busyUser = true);
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');

      // Nếu admin quét/nhập thẳng uid (document id) thì nhận luôn
      final byId = await usersRef.doc(q).get();
      if (!mounted || seq != _userLookupSeq) return;
      if (byId.exists) {
        final data = byId.data();
        if (data != null) {
          setState(() => _user = _UserPreview.fromDoc(byId.id, data));
          return;
        }
      }

      // Thử theo email
      final byEmail = await usersRef.where('email', isEqualTo: q).limit(1).get();
      if (!mounted || seq != _userLookupSeq) return;
      if (byEmail.docs.isNotEmpty) {
        final doc = byEmail.docs.first;
        setState(() => _user = _UserPreview.fromDoc(doc.id, doc.data()));
        return;
      }

      // Thử theo MSSV (studentCode)
      final byStudentCode = await usersRef.where('studentCode', isEqualTo: q).limit(1).get();
      if (!mounted || seq != _userLookupSeq) return;
      if (byStudentCode.docs.isNotEmpty) {
        final doc = byStudentCode.docs.first;
        setState(() => _user = _UserPreview.fromDoc(doc.id, doc.data()));
        return;
      }

      if (!mounted || seq != _userLookupSeq) return;
      setState(() => _user = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.studentNotFound)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.studentLookupError('$e'))));
      }
    } finally {
      if (mounted && seq == _userLookupSeq) {
        setState(() => _busyUser = false);
        _repairBookFieldAfterUserFlow(bookBefore, previewBefore, '');
      }
    }
  }

  Future<void> _createBorrowRecord() async {
    final t = AppLocalizations.of(context)!;
    final book = _book;
    final user = _user;
    if (book == null || user == null) return;

    if (!user.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.studentLockedCannotBorrow)),
      );
      return;
    }

    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.needReSignIn)));
      return;
    }

    final today = _dateOnly(DateTime.now());
    final dueDay = _dateOnly(_dueDate);
    final minDue = today.add(Duration(days: BorrowPolicy.minLoanDays));
    final maxDue = today.add(Duration(days: BorrowPolicy.maxLoanDays));
    if (dueDay.isBefore(minDue) || dueDay.isAfter(maxDue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.borrowDueDateErrorRange)),
      );
      return;
    }

    setState(() => _busySubmit = true);
    try {
      final db = FirebaseFirestore.instance;

      final dup = await db
          .collection('borrow_records')
          .where('userId', isEqualTo: user.id)
          .where('bookId', isEqualTo: book.id)
          .where('status', isEqualTo: 'borrowing')
          .limit(1)
          .get();
      if (dup.docs.isNotEmpty) {
        if (mounted) {
          setState(() => _busySubmit = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.borrowSameBookAlready)),
          );
        }
        return;
      }

      final maxB = await LibraryConfigService.maxActiveBorrowsPerUser();
      final activeAll = await db
          .collection('borrow_records')
          .where('userId', isEqualTo: user.id)
          .where('status', isEqualTo: 'borrowing')
          .get();
      if (activeAll.docs.length >= maxB) {
        if (mounted) {
          setState(() => _busySubmit = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.borrowMaxActiveReached('$maxB'))),
          );
        }
        return;
      }

      final dueDate = _dueAtEndOfDay(_dueDate);
      final bookRef = db.collection('books').doc(book.id);
      final userRef = db.collection('users').doc(user.id);
      final borrowRef = db.collection('borrow_records').doc();

      await db.runTransaction((tx) async {
        final bookSnap = await tx.get(bookRef);
        final bookData = bookSnap.data();
        if (bookData == null) {
          throw Exception(t.borrowBookNotFound);
        }

        final userSnap = await tx.get(userRef);
        if (!userSnap.exists) {
          throw Exception(t.borrowStudentProfileMissing(user.id));
        }
        final userData = userSnap.data();

        final available = _readInt(bookData['availableQuantity'] ?? bookData['available'], 0);
        if (available <= 0) {
          throw Exception(t.borrowOutOfStock);
        }

        // Chỉ đổi availableQuantity + updatedAt để khớp firestore.rules khi user không phải staff
        // (rule chỉ cho phép 2 field đó cho luồng tự mượn). Thống kê mượn lấy từ collection borrow_records.
        tx.update(bookRef, {
          'availableQuantity': available - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Dùng số tường minh thay vì FieldValue.increment để rule `hasOnly(['totalBorrowed'])` cho manager khớp ổn định.
        final prevBorrowed = _readInt(userData?['totalBorrowed'], 0);
        tx.update(userRef, {
          'totalBorrowed': prevBorrowed + 1,
        });

        tx.set(borrowRef, {
          'userId': user.id,
          'bookId': book.id,
          // Snapshot để lịch sử vẫn hiển thị khi sách bị xóa.
          'bookTitleSnapshot': (bookData['title'] ?? '').toString(),
          'bookAuthorSnapshot': (bookData['author'] ?? '').toString(),
          'bookImageUrlSnapshot': (bookData['imageUrl'] ?? '').toString(),
          'borrowDate': FieldValue.serverTimestamp(),
          'dueDate': Timestamp.fromDate(dueDate),
          'returnDate': null,
          'status': 'borrowing',
          'fineAmount': 0,
          'processedBy': adminUid,
        });
      });

      try {
        final d = dueDate;
        final dueStr =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        await db.collection('notifications').add({
          'userId': user.id,
          'title': t.borrowNotificationTitle,
          'body': t.borrowNotificationBody(book.title, dueStr),
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      } catch (_) {}

      if (!mounted) return;
      final theme = Theme.of(context);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: Text(AppLocalizations.of(dialogCtx)!.borrowCreatedSuccessTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(dialogCtx)!.borrowCreatedSuccessBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Center(
                  child: QrImageView(
                    data: LibraryQrPayload.borrowRecordForReturn(borrowRef.id),
                    size: 188,
                    version: QrVersions.auto,
                    gapless: true,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  borrowRef.id,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(dialogCtx)!.commonDone),
            ),
          ],
        ),
      );
    } on FirebaseException catch (e) {
      if (mounted) {
        final msg = e.message ?? e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'permission-denied'
                  ? t.borrowPermissionDeniedHelp
                  : t.borrowCreateFailedWithCode(e.code, msg),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.borrowFailed('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busySubmit = false);
    }
  }
}

/// Thanh bước: sách → sinh viên → tạo phiếu (chỉ bật khi đủ điều kiện).
class _BorrowFlowSteps extends StatelessWidget {
  final bool bookOk;
  final bool userOk;

  const _BorrowFlowSteps({
    required this.bookOk,
    required this.userOk,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final t = AppLocalizations.of(context)!;
    Widget step(int n, String label, bool done, bool highlight) {
      final color = done ? c.primary : c.outline;
      return Expanded(
        child: Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: done ? c.primaryContainer : c.surfaceContainerHighest,
              child: done
                  ? Icon(Icons.check, size: 16, color: c.onPrimaryContainer)
                  : Text('$n', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: highlight ? c.primary : c.onSurfaceVariant,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            step(1, t.borrowStepBook, bookOk, !bookOk),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(Icons.chevron_right, size: 18, color: c.outline),
            ),
            step(2, t.borrowStepStudent, userOk, bookOk && !userOk),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(Icons.chevron_right, size: 18, color: c.outline),
            ),
            step(3, t.borrowStepCreateTicket, bookOk && userOk, bookOk && userOk),
          ],
        ),
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String value;
  final double width;
  const _ReadonlyField({required this.value, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
          Icon(Icons.calendar_today, color: theme.colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

class _DueDatePickerTile extends StatelessWidget {
  final double width;
  final String valueText;
  final bool enabled;
  final VoidCallback onTap;

  const _DueDatePickerTile({
    required this.width,
    required this.valueText,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  valueText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: enabled ? null : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
              Icon(
                Icons.edit_calendar_outlined,
                color: enabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookPreview {
  final String id;
  final String title;
  final String author;
  final String category;
  final String isbn;
  final String imageUrl;
  final int quantity;
  final int available;

  const _BookPreview({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.isbn,
    required this.imageUrl,
    required this.quantity,
    required this.available,
  });

  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory _BookPreview.fromDoc(String id, Map<String, dynamic> data) {
    final quantity = _asInt(data['quantity']);
    final available = _asInt(data['availableQuantity'] ?? data['available'], quantity);
    return _BookPreview(
      id: id,
      title: data['title']?.toString() ?? '',
      author: data['author']?.toString() ?? '',
      category: (data['category'] ?? data['categoryId'] ?? kDefaultBookCategory)?.toString() ?? kDefaultBookCategory,
      isbn: data['isbn']?.toString() ?? '',
      imageUrl: (data['imageUrl'] ?? '').toString(),
      quantity: quantity,
      available: available,
    );
  }
}

class _UserPreview {
  final String id;
  final String fullName;
  final String email;
  final String studentCode;
  final bool isActive;

  const _UserPreview({
    required this.id,
    required this.fullName,
    required this.email,
    required this.studentCode,
    required this.isActive,
  });

  factory _UserPreview.fromDoc(String id, Map<String, dynamic> data) {
    final activeRaw = data['isActive'];
    final isActive = activeRaw is bool
        ? activeRaw
        : (activeRaw == null
            ? true
            : (activeRaw.toString().toLowerCase() == 'true' || activeRaw.toString() == '1'));
    return _UserPreview(
      id: id,
      fullName: data['fullName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      studentCode: data['studentCode']?.toString() ?? '',
      isActive: isActive,
    );
  }
}

class _BookCard extends StatelessWidget {
  final _BookPreview book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = book.available > 0 ? Colors.green : Colors.red;
    return Card(
      child: ListTile(
        isThreeLine: true,
        leading: buildBookCoverDisplay(
          imageRef: book.imageUrl,
          width: 48,
          height: 64,
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${book.author} • ${displayBookCategory(t, book.category)}\n${t.isbnLabel(book.isbn, book.available, book.quantity)}',
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 72, minHeight: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${book.available}/${book.quantity}',
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
              const SizedBox(height: 2),
              Text(t.remainingTotalLabel, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final _UserPreview user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locked = !user.isActive;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: locked ? Colors.red.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
          child: Icon(Icons.person, color: locked ? Colors.red : Colors.blue),
        ),
        title: Text(user.fullName.isEmpty ? t.userNamePlaceholder : user.fullName),
        subtitle: Text(
          '${user.email}${user.studentCode.isNotEmpty ? ' • ${user.studentCode}' : ''}',
        ),
        trailing: locked
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(t.lockedShort, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
