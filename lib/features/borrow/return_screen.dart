import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/book_cover_from_firestore.dart';
import '../../core/utils/library_qr_payload.dart';
import '../shared/qr_scanner_screen.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/borrow_return_service.dart';

String _returnBrCodeMessage(AppLocalizations t, String code) {
  switch (code) {
    case 'book_not_found':
      return t.brErrBookNotFound;
    case 'invalid_book_data':
      return t.brErrInvalidBookData;
    default:
      return t.genericErrorWithMessage(code);
  }
}

/// Màn hình trả sách (Admin) - Firestore
class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final _ticketController = TextEditingController();

  bool _isLoading = false;
  _BorrowRecordPreview? _record;
  int _finePerDay = 0;
  bool _routeArgsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFinePerDay();
  }

  Future<void> _loadFinePerDay() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('library_settings')
          .doc('config')
          .get();
      final data = doc.data();
      final finePerDay = data?['finePerDay'];
      if (finePerDay is int && mounted) {
        setState(() => _finePerDay = finePerDay);
      }
    } catch (_) {
      // giữ mặc định 0
    }
  }

  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeArgsLoaded) return;
    _routeArgsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : null;
    final borrowRecordId = map?['borrowRecordId']?.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (borrowRecordId != null && borrowRecordId.isNotEmpty) {
        _ticketController.text =
            '${LibraryQrPayload.returnPrefix}$borrowRecordId';
        await _lookupByBorrowRecordId(borrowRecordId);
        return;
      }
      // Không tự động tìm/đối chiếu để tránh “tự trả” khi chỉ mở màn từ nơi khác.
      // Thủ thư chủ động bấm TÌM hoặc quét phiếu mượn (LIB_RET:...) để trả.
    });
  }

  int _readInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  Future<void> _scanBorrowTicketQr() async {
    final t = AppLocalizations.of(context)!;
    final value = await Navigator.push<String?>(
      context,
      MaterialPageRoute<String?>(
        builder: (_) => QrScannerScreen(
          title: t.scanBorrowTicketTitle,
          hint: t.scanBorrowTicketHint,
        ),
      ),
    );
    if (value == null || value.trim().isEmpty) return;
    final p = LibraryQrParseResult.parse(value.trim());
    String? id;
    if (p.borrowRecordId != null && p.borrowRecordId!.trim().isNotEmpty) {
      id = p.borrowRecordId!.trim();
    } else {
      final k = p.bookLookupKey.trim();
      id = k.isNotEmpty ? k : null;
    }
    if (id == null || id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.cannotReadBorrowTicket)));
      return;
    }
    _ticketController.text = '${LibraryQrPayload.returnPrefix}$id';
    await _lookupByBorrowRecordId(id);
  }

  Future<void> _lookupByBorrowRecordId(String id) async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('borrow_records')
          .doc(id)
          .get();
      if (!doc.exists) {
        setState(() => _record = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.borrowTicketNotFound),
            ),
          );
        }
        return;
      }
      final data = doc.data();
      if (data == null) {
        setState(() => _record = null);
        return;
      }
      final status = (data['status'] ?? '') as String;
      if (status != 'borrowing') {
        setState(() => _record = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.borrowTicketNotActive,
              ),
            ),
          );
        }
        return;
      }
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      final record = await _BorrowRecordPreview.fromBorrowSnapshot(
        doc,
        userNamePlaceholder: loc.userNamePlaceholder,
      );
      setState(() => _record = record);
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.returnLoadRecordError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.returnBookTitle)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.statsPermissionDenied,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.currentBorrowsPermissionHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.commonClose),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.returnBookTitle), scrolledUnderElevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReturnSearchPanel(
                    theme: theme,
                    t: t,
                    ticketController: _ticketController,
                    isLoading: _isLoading,
                    onScan: !kIsWeb ? _scanBorrowTicketQr : null,
                    onFind: _lookupBorrowTicketFromInput,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    t.borrowRecordLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _record == null
                        ? _ReturnEmptyTicketCard(
                            key: const ValueKey('empty'),
                            theme: theme,
                            message: t.borrowRecordNotSelected,
                          )
                        : _BorrowRecordCard(
                            key: ValueKey(_record!.id),
                            record: _record!,
                            finePerDay: _finePerDay,
                            onClear: _isLoading
                                ? null
                                : () => setState(() => _record = null),
                            onConfirm: _isLoading ? null : _confirmReturn,
                          ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    t.returnRecentHistory,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RecentReturnsList(
                    adminUid: FirebaseAuth.instance.currentUser?.uid,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _lookupBorrowTicketFromInput() async {
    final t = AppLocalizations.of(context)!;
    final raw = _ticketController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.cannotReadBorrowTicket)));
      return;
    }
    final parsed = LibraryQrParseResult.parse(raw);
    final id = (parsed.borrowRecordId ?? parsed.bookLookupKey).trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.cannotReadBorrowTicket)));
      return;
    }
    await _lookupByBorrowRecordId(id);
  }

  Future<void> _confirmReturn() async {
    final t = AppLocalizations.of(context)!;
    final record = _record;
    if (record == null) return;

    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.returnNeedRelogin)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = FirebaseFirestore.instance;
      final bookRef = db.collection('books').doc(record.bookId);
      final borrowRef = db.collection('borrow_records').doc(record.id);

      final now = DateTime.now();
      final due = record.dueDate;
      final daysLate = due == null ? 0 : _daysLate(due, now);
      final fineAmount = daysLate > 0 ? daysLate * _finePerDay : 0;
      final status = daysLate > 0 ? 'late' : 'returned';

      await db.runTransaction((tx) async {
        final bookSnap = await tx.get(bookRef);
        final bookData = bookSnap.data();
        if (bookData == null) {
          throw BorrowReturnException('book_not_found');
        }
        final available = _readInt(
          bookData['availableQuantity'] ?? bookData['available'],
          0,
        );

        tx.update(bookRef, {
          'availableQuantity': available + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.update(borrowRef, {
          'returnDate': FieldValue.serverTimestamp(),
          'status': status,
          'fineAmount': fineAmount,
          'processedBy': adminUid,
        });
      });

      try {
        await db.collection('notifications').add({
          'userId': record.userId,
          'title': status == 'late'
              ? t.notifReturnLateTitle
              : t.notifReturnOnTimeTitle,
          'body': status == 'late'
              ? t.notifReturnLateBody(record.bookTitle, '$daysLate')
              : t.notifReturnDeskBody(record.bookTitle),
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.returnSuccessToast)));
      setState(() => _record = null);
    } on BorrowReturnException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_returnBrCodeMessage(t, e.code))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.returnConfirmError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _daysLate(DateTime due, DateTime now) {
    final dueDateOnly = DateTime(due.year, due.month, due.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final diff = nowDateOnly.difference(dueDateOnly).inDays;
    return diff > 0 ? diff : 0;
  }
}

/// Khối tìm phiếu — nền card, CTA quét nổi bật (mobile), ô nhập + nút tìm.
class _ReturnSearchPanel extends StatelessWidget {
  const _ReturnSearchPanel({
    required this.theme,
    required this.t,
    required this.ticketController,
    required this.isLoading,
    required this.onScan,
    required this.onFind,
  });

  final ThemeData theme;
  final AppLocalizations t;
  final TextEditingController ticketController;
  final bool isLoading;
  final VoidCallback? onScan;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    final c = theme.colorScheme;
    final borderColor = theme.dividerColor.withValues(alpha: 0.38);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.manage_search_rounded,
                    color: c.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.returnFindTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              t.returnFindBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (onScan != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.tonalIcon(
                  onPressed: isLoading ? null : onScan,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 24),
                  label: Text(t.scanBorrowTicketTitle),
                  style: FilledButton.styleFrom(
                    alignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(height: 1, color: borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    t.commonOr,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: c.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Expanded(child: Divider(height: 1, color: borderColor)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('admin_search_ticket_field'),
              controller: ticketController,
              enabled: !isLoading,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onFind(),
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                filled: true,
                fillColor: c.surface,
                hintText: t.scanBorrowTicketHint,
                hintMaxLines: 2,
                hintStyle: TextStyle(
                  color: c.onSurfaceVariant.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.tag_rounded,
                  color: c.primary.withValues(alpha: 0.88),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: c.primary, width: 1.6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onFind,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.search_rounded, size: 22),
                label: Text(
                  t.findBorrowingRecord,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnEmptyTicketCard extends StatelessWidget {
  const _ReturnEmptyTicketCard({
    super.key,
    required this.theme,
    required this.message,
  });

  final ThemeData theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        color: c.surfaceContainerHighest.withValues(alpha: 0.28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: c.outline.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: c.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BorrowRecordPreview {
  final String id;
  final String userId;
  final String bookId;
  final DateTime? dueDate;
  final String bookTitle;
  final String userLabel; // fullName + studentCode/email

  const _BorrowRecordPreview({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.dueDate,
    required this.bookTitle,
    required this.userLabel,
  });

  static Future<_BorrowRecordPreview> fromBorrowSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String userNamePlaceholder,
  }) async {
    final data = doc.data();
    if (data == null) {
      throw StateError('borrow record empty');
    }
    final userId = (data['userId'] ?? '') as String;
    final bookId = (data['bookId'] ?? '') as String;
    final dueDate = (data['dueDate'] as Timestamp?)?.toDate();

    final db = FirebaseFirestore.instance;
    final bookSnap = await db.collection('books').doc(bookId).get();
    final bookTitle = (bookSnap.data()?['title'] ?? '') as String;

    final userSnap = await db.collection('users').doc(userId).get();
    final u = userSnap.data() ?? {};
    final fullName = (u['fullName'] ?? '') as String;
    final studentCode = (u['studentCode'] ?? '') as String;
    final email = (u['email'] ?? '') as String;
    final userLabel = [
      fullName.isNotEmpty ? fullName : userNamePlaceholder,
      studentCode.isNotEmpty ? studentCode : email,
    ].where((e) => e.isNotEmpty).join(' - ');

    return _BorrowRecordPreview(
      id: doc.id,
      userId: userId,
      bookId: bookId,
      dueDate: dueDate,
      bookTitle: bookTitle,
      userLabel: userLabel,
    );
  }
}

class _BorrowRecordCard extends StatelessWidget {
  final _BorrowRecordPreview record;
  final int finePerDay;
  final VoidCallback? onClear;
  final VoidCallback? onConfirm;

  const _BorrowRecordCard({
    super.key,
    required this.record,
    required this.finePerDay,
    required this.onClear,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final due = record.dueDate;
    final daysLate = (due == null) ? 0 : _daysLate(due, now);
    final fine = daysLate > 0 ? daysLate * finePerDay : 0;

    final dueText = due == null ? '—' : _formatDate(due);
    final dueColor = daysLate > 0 ? AppColors.error : AppColors.success;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.38)),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dueColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: BookCoverFromBookId(
                    bookId: record.bookId,
                    width: 52,
                    height: 70,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.bookTitle.isEmpty
                            ? t.returnMissingBookName
                            : record.bookTitle,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 17,
                          height: 1.25,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.userLabel,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: dueColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          t.returnDueDateLabel(dueText),
                          style: AppTextStyles.small.copyWith(
                            color: dueColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (daysLate > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.returnLateDaysFine(daysLate, fine),
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const Key('confirm_return_button'),
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  t.returnConfirmButton,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onClear,
                child: Text(t.returnDeleteRecord),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _daysLate(DateTime due, DateTime now) {
    final dueDateOnly = DateTime(due.year, due.month, due.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final diff = nowDateOnly.difference(dueDateOnly).inDays;
    return diff > 0 ? diff : 0;
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }
}

class _RecentReturnsList extends StatelessWidget {
  final String? adminUid;
  const _RecentReturnsList({required this.adminUid});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = adminUid;
    if (uid == null) {
      return const SizedBox.shrink();
    }

    final query = FirebaseFirestore.instance
        .collection('borrow_records')
        .where('processedBy', isEqualTo: uid)
        .where('status', whereIn: const ['returned', 'late'])
        .orderBy('returnDate', descending: true)
        .limit(10);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return Text(t.returnCannotLoadHistory);
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                t.returnNoRecentReturns,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final status = (data['status'] ?? '') as String;
            final fine = (data['fineAmount'] as num?)?.toInt() ?? 0;
            final isLate = status == 'late';
            final iconColor = isLate ? AppColors.error : AppColors.success;
            final bg = isLate
                ? AppColors.error.withValues(alpha: 0.08)
                : AppColors.success.withValues(alpha: 0.08);
            final bookId = (data['bookId'] ?? '') as String;
            final snapTitle = (data['bookTitleSnapshot'] ?? '')
                .toString()
                .trim();
            final title = snapTitle.isNotEmpty
                ? snapTitle
                : t.returnBookPrefix(bookId);

            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: bg,
                      child: Icon(
                        isLate ? Icons.schedule_rounded : Icons.check_rounded,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLate
                                ? t.returnLateWithFine(fine)
                                : t.returnOnTime,
                            style: AppTextStyles.caption.copyWith(
                              color: isLate
                                  ? AppColors.error
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              fontWeight: isLate
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
