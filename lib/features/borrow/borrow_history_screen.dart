import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/book_cover_display.dart';
import '../../core/utils/book_cover_from_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình lịch sử mượn sách (Admin/Sinh viên) - Firestore
class BorrowHistoryScreen extends StatefulWidget {
  const BorrowHistoryScreen({super.key, this.embedInTab = false});

  /// Khi true: chỉ trả về nội dung (dùng nhúng trong tab), không dùng Scaffold
  final bool embedInTab;

  @override
  State<BorrowHistoryScreen> createState() => _BorrowHistoryScreenState();
}

class _BorrowHistoryScreenState extends State<BorrowHistoryScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isStaff = AppUser.isStaff;
    final statusOptions = [
      _StatusOption('all', t.statusAll),
      _StatusOption('borrowing', t.statusBorrowing),
      _StatusOption('returned', t.statusReturned),
      _StatusOption('late', t.statusLate),
    ];

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('borrow_records');
    if (!isStaff && uid != null) {
      query = query.where('userId', isEqualTo: uid);
    }
    query = query.orderBy('borrowDate', descending: true).limit(100);

    // Firestore không cho whereIn với orderBy linh hoạt ở mọi trường hợp, nên lọc status phía client cho đơn giản.
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusOptions.map((s) {
              final selected = _filterStatus == s.id;
              return ChoiceChip(
                label: Text(s.label),
                selected: selected,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                onSelected: (_) => setState(() => _filterStatus = s.id),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(t.cannotLoadBorrowHistory));
              }

              final docs = snapshot.data?.docs ?? [];
              var items = docs.map((d) => _BorrowItem.fromDoc(d)).toList();

              if (_filterStatus != 'all') {
                items = items.where((i) => i.status == _filterStatus).toList();
              }

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    isStaff ? t.noBorrowHistoryStaff : t.noBorrowHistoryStudent,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final r = items[index];
                  final statusColor = switch (r.status) {
                    'late' => AppColors.error,
                    'returned' => AppColors.success,
                    _ => AppColors.primary,
                  };

                  final statusLabel = r.statusLabel(t);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.28)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: statusColor.withValues(alpha: 0.42), width: 1.4),
                              ),
                              child: r.bookImageUrlSnapshot.trim().isNotEmpty
                                  ? buildBookCoverDisplay(
                                      imageRef: r.bookImageUrlSnapshot,
                                      width: 44,
                                      height: 58,
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : BookCoverFromBookId(
                                      bookId: r.bookId,
                                      width: 44,
                                      height: 58,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _HistoryBookTitle(
                                          bookId: r.bookId,
                                          snapshotTitle: r.bookTitleSnapshot,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusChip(label: statusLabel, isLate: r.status == 'late'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.borrowedPrefix(r.borrowDateText, r.returnDateText),
                                    style: AppTextStyles.small.copyWith(
                                      fontSize: 11.8,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (r.fineAmount > 0) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        t.finePrefix('${r.fineAmount}'),
                                        style: AppTextStyles.small.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                  if (isStaff) ...[
                                    const SizedBox(height: 6),
                                    DefaultTextStyle(
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 11.5,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                                      ),
                                      child: _HistoryUserLabel(userId: r.userId),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedInTab) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.borrowHistoryTitle2),
      ),
      body: body,
    );
  }
}

class _StatusOption {
  final String id;
  final String label;

  const _StatusOption(this.id, this.label);
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isLate;

  const _StatusChip({required this.label, required this.isLate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    Color color = AppColors.success;
    if (label == t.statusBorrowing) color = AppColors.primary;
    if (isLate) color = AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: AppTextStyles.small.copyWith(color: color)),
    );
  }
}

class _BorrowItem {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitleSnapshot;
  final String bookImageUrlSnapshot;
  final String status; // borrowing | returned | late
  final int fineAmount;
  final DateTime? borrowDate;
  final DateTime? returnDate;

  const _BorrowItem({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitleSnapshot,
    required this.bookImageUrlSnapshot,
    required this.status,
    required this.fineAmount,
    required this.borrowDate,
    required this.returnDate,
  });

  String statusLabel(AppLocalizations t) {
    switch (status) {
      case 'borrowing':
        return t.statusBorrowing;
      case 'late':
        return t.statusLate;
      default:
        return t.statusReturned;
    }
  }

  String get borrowDateText => borrowDate == null ? '—' : _formatDate(borrowDate!);
  String get returnDateText => returnDate == null ? '—' : _formatDate(returnDate!);

  static _BorrowItem fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return _BorrowItem(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      bookId: (data['bookId'] ?? '') as String,
      bookTitleSnapshot: (data['bookTitleSnapshot'] ?? '').toString(),
      bookImageUrlSnapshot: (data['bookImageUrlSnapshot'] ?? '').toString(),
      status: (data['status'] ?? 'borrowing') as String,
      fineAmount: (data['fineAmount'] as num?)?.toInt() ?? 0,
      borrowDate: (data['borrowDate'] as Timestamp?)?.toDate(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
    );
  }

  static String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }
}

class _HistoryBookTitle extends StatelessWidget {
  final String bookId;
  final String? snapshotTitle;
  const _HistoryBookTitle({required this.bookId, this.snapshotTitle});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (bookId.isEmpty) return Text(t.missingBookId, style: AppTextStyles.h3);

    final snap = (snapshotTitle ?? '').trim();
    if (snap.isNotEmpty) {
      return Text(
        snap,
        style: AppTextStyles.h3,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
      builder: (context, snapshot) {
        final title = snapshot.data?.data()?['title']?.toString();
        return Text(
          (title == null || title.isEmpty) ? '${t.bookLabel} ($bookId)' : title,
          style: AppTextStyles.h3,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

class _HistoryUserLabel extends StatelessWidget {
  final String userId;
  const _HistoryUserLabel({required this.userId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (userId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) return const SizedBox.shrink();
        final fullName = (data['fullName'] ?? '') as String;
        final studentCode = (data['studentCode'] ?? '') as String;
        final email = (data['email'] ?? '') as String;
        final label = [
          fullName.isNotEmpty ? fullName : t.userNamePlaceholder,
          studentCode.isNotEmpty ? studentCode : email,
        ].where((e) => e.isNotEmpty).join(' - ');

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(label, style: AppTextStyles.caption),
        );
      },
    );
  }
}
