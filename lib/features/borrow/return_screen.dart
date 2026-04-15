import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  final _bookCodeController = TextEditingController();
  final _userQueryController = TextEditingController();

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
      final doc = await FirebaseFirestore.instance.collection('library_settings').doc('config').get();
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
    _bookCodeController.dispose();
    _userQueryController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeArgsLoaded) return;
    _routeArgsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : null;
    final bookId = map?['bookId']?.toString();
    final userId = map?['userId']?.toString();
    final borrowRecordId = map?['borrowRecordId']?.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (borrowRecordId != null && borrowRecordId.isNotEmpty) {
        await _lookupByBorrowRecordId(borrowRecordId);
        return;
      }
      if (bookId != null && bookId.isNotEmpty) {
        _bookCodeController.text = bookId;
      }
      if (userId != null && userId.isNotEmpty) {
        _userQueryController.text = userId;
      }
      final code = _bookCodeController.text.trim();
      final uq = _userQueryController.text.trim();
      if (code.isNotEmpty && uq.isNotEmpty) {
        await _lookupBorrowingRecord();
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.cannotReadBorrowTicket)),
      );
      return;
    }
    await _lookupByBorrowRecordId(id);
  }

  Future<void> _lookupByBorrowRecordId(String id) async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('borrow_records').doc(id).get();
      if (!doc.exists) {
        setState(() => _record = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.borrowTicketNotFound)));
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
            SnackBar(content: Text(AppLocalizations.of(context)!.borrowTicketNotActive)),
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
      _bookCodeController.text = record.bookId;
      _userQueryController.text = record.userId;
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnLoadRecordError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.returnBookTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.returnFindTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              t.returnFindBody,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (!kIsWeb) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _scanBorrowTicketQr,
                  icon: const Icon(Icons.confirmation_number_outlined, size: 20),
                    label: Text(t.scanBorrowTicketTitle),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(t.enterBookCode, style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              controller: _bookCodeController,
              decoration: InputDecoration(
                hintText: t.bookIdOrIsbnHint,
                prefixIcon: const Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 12),
            Text(t.studentQueryLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              controller: _userQueryController,
              decoration: InputDecoration(
                hintText: t.studentQueryHint,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _lookupBorrowingRecord,
                icon: const Icon(Icons.search),
                label: Text(t.findBorrowingRecord),
              ),
            ),
            const SizedBox(height: 16),

            Text(t.borrowRecordLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_record == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    t.borrowRecordNotSelected,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              _BorrowRecordCard(
                record: _record!,
                finePerDay: _finePerDay,
                onClear: _isLoading ? null : () => setState(() => _record = null),
                onConfirm: _isLoading ? null : _confirmReturn,
              ),

            const SizedBox(height: 16),
            Text(t.returnRecentHistory, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _RecentReturnsList(adminUid: FirebaseAuth.instance.currentUser?.uid),
          ],
        ),
      ),
    );
  }

  Future<void> _lookupBorrowingRecord() async {
    final t = AppLocalizations.of(context)!;
    final code = _bookCodeController.text.trim();
    final uq = _userQueryController.text.trim();
    if (code.isEmpty || uq.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.returnEnterBookAndStudent)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = FirebaseFirestore.instance;

      // Resolve bookId
      String? bookId;
      final byId = await db.collection('books').doc(code).get();
      if (byId.exists) {
        bookId = byId.id;
      } else {
        final byIsbn = await db.collection('books').where('isbn', isEqualTo: code).limit(1).get();
        if (byIsbn.docs.isNotEmpty) {
          bookId = byIsbn.docs.first.id;
        }
      }

      if (bookId == null) {
        setState(() => _record = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnBookNotFound)));
        }
        return;
      }

      // Resolve userId (nếu admin truyền thẳng userId thì nhận luôn)
      String? userId;
      final directUserId = uq;
      if (directUserId.isNotEmpty) {
        final userById = await db.collection('users').doc(directUserId).get();
        if (userById.exists) {
          userId = userById.id;
        }
      }

      final byEmail = await db.collection('users').where('email', isEqualTo: uq).limit(1).get();
      if (byEmail.docs.isNotEmpty) {
        userId = byEmail.docs.first.id;
      } else {
        final byStudentCode = await db.collection('users').where('studentCode', isEqualTo: uq).limit(1).get();
        if (byStudentCode.docs.isNotEmpty) {
          userId = byStudentCode.docs.first.id;
        }
      }

      if (userId == null) {
        setState(() => _record = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnStudentNotFound)));
        }
        return;
      }

      // Find active borrow record
      final q = await db
          .collection('borrow_records')
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'borrowing')
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        setState(() => _record = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.returnNoActiveBorrowFound)),
          );
        }
        return;
      }

      final doc = q.docs.first;
      final record = await _BorrowRecordPreview.fromBorrowDoc(
        doc,
        userNamePlaceholder: t.userNamePlaceholder,
      );
      setState(() => _record = record);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnLookupError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmReturn() async {
    final t = AppLocalizations.of(context)!;
    final record = _record;
    if (record == null) return;

    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnNeedRelogin)));
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
        final available = _readInt(bookData['availableQuantity'] ?? bookData['available'], 0);

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
          'title': status == 'late' ? t.notifReturnLateTitle : t.notifReturnOnTimeTitle,
          'body': status == 'late'
              ? t.notifReturnLateBody(record.bookTitle, '$daysLate')
              : t.notifReturnDeskBody(record.bookTitle),
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnSuccessToast)));
      setState(() => _record = null);
    } on BorrowReturnException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_returnBrCodeMessage(t, e.code))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.returnConfirmError('$e'))));
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

  static Future<_BorrowRecordPreview> fromBorrowDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required String userNamePlaceholder,
  }) {
    return fromBorrowSnapshot(doc, userNamePlaceholder: userNamePlaceholder);
  }

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BookCoverFromBookId(
                  bookId: record.bookId,
                  width: 48,
                  height: 64,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.bookTitle.isEmpty ? t.returnMissingBookName : record.bookTitle, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(record.userLabel, style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Text(
                        t.returnDueDateLabel(dueText),
                        style: AppTextStyles.small.copyWith(color: dueColor),
                      ),
                      if (daysLate > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          t.returnLateDaysFine(daysLate, fine),
                          style: AppTextStyles.small.copyWith(color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    child: Text(t.returnDeleteRecord),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: Text(t.returnConfirmButton),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'finePerDay: $finePerDay',
              style: theme.textTheme.bodySmall,
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
          return Text(t.returnNoRecentReturns);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final status = (data['status'] ?? '') as String;
            final fine = (data['fineAmount'] ?? 0) as int;
            final iconColor = status == 'late' ? AppColors.error : AppColors.success;
            final icon = status == 'late' ? Icons.warning_amber_rounded : Icons.check_circle;
            final bookId = (data['bookId'] ?? '') as String;

            return Card(
              child: ListTile(
                leading: Icon(icon, color: iconColor),
                title: Text(t.returnBookPrefix(bookId), style: AppTextStyles.body),
                subtitle: Text(
                  status == 'late' ? t.returnLateWithFine(fine) : t.returnOnTime,
                  style: AppTextStyles.caption,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
