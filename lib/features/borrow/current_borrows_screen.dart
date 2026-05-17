import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/book_cover_from_firestore.dart';
import '../../core/utils/library_qr_payload.dart';
import '../../gen/l10n/app_localizations.dart';
import 'data/borrow_repository.dart';

/// Màn hình sách đang mượn — [BorrowRepository], phân trang + kéo refresh (không stream cả query).
class CurrentBorrowsScreen extends StatefulWidget {
  const CurrentBorrowsScreen({super.key, this.embedInTab = false});

  /// Khi true: chỉ trả về nội dung (dùng nhúng trong tab), không dùng Scaffold
  final bool embedInTab;

  @override
  State<CurrentBorrowsScreen> createState() => _CurrentBorrowsScreenState();
}

class _CurrentBorrowsScreenState extends State<CurrentBorrowsScreen> {
  final BorrowRepository _repo = BorrowRepository();
  final ScrollController _scrollController = ScrollController();

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String? get _userIdEquals {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (AppUser.isStaff) return null;
    return uid;
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    final pos = _scrollController.position;
    if (!pos.hasViewportDimension) return;
    if (pos.pixels >= pos.maxScrollExtent * 0.88) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _loadError = null;
      _docs.clear();
      _cursor = null;
      _hasMore = true;
    });
    try {
      final page = await _repo.fetchActiveBorrowsPage(
        userIdEquals: _userIdEquals,
        pageSize: BorrowRepository.defaultPageSize,
        startAfter: null,
      );
      if (!mounted) return;
      setState(() {
        _docs.addAll(page.docs);
        _cursor = page.lastDoc;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _cursor == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _repo.fetchActiveBorrowsPage(
        userIdEquals: _userIdEquals,
        pageSize: BorrowRepository.defaultPageSize,
        startAfter: _cursor,
      );
      if (!mounted) return;
      setState(() {
        _docs.addAll(page.docs);
        _cursor = page.lastDoc;
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.genericErrorWithMessage('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isStaff = AppUser.isStaff;

    final body = _buildBody(context, t, isStaff);

    if (widget.embedInTab) return body;
    return Scaffold(
      appBar: AppBar(title: Text(t.currentBorrowsTitle)),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations t, bool isStaff) {
    if (_loading && _docs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null && _docs.isEmpty) {
      final err = _loadError?.toString() ?? 'Unknown error';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.cannotLoadCurrentBorrows),
              const SizedBox(height: 8),
              Text(
                err,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                t.currentBorrowsPermissionHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadFirstPage,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(t.loadMore),
              ),
            ],
          ),
        ),
      );
    }
    if (_docs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFirstPage,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.35,
              child: Center(
                child: Text(
                  isStaff ? t.noActiveBorrowsStaff : t.noActiveBorrowsStudent,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _docs.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _docs.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final theme = Theme.of(context);
          final doc = _docs[index];
          final data = doc.data();
          final bookId = (data['bookId'] ?? '') as String;
          final userId = (data['userId'] ?? '') as String;
          final dueDate = (data['dueDate'] as Timestamp?)?.toDate();

          final daysLeft = dueDate == null ? null : _daysLeft(dueDate);
          final warning = daysLeft != null && daysLeft <= 3;
          final late = daysLeft != null && daysLeft < 0;
          final borrowDate = (data['borrowDate'] as Timestamp?)?.toDate();
          final fineAmount = (data['fineAmount'] as num?)?.toInt() ?? 0;
          final processedBy = (data['processedBy'] ?? '').toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: late
                        ? AppColors.error
                        : (warning
                              ? AppColors.warning
                              : theme.dividerColor.withValues(alpha: 0.25)),
                    width: late || warning ? 2 : 1,
                  ),
                ),
                child: BookCoverFromBookId(
                  bookId: bookId,
                  width: 48,
                  height: 64,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: _BookTitle(bookId: bookId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    t.dueDatePrefix(
                      dueDate == null ? '—' : _formatDate(dueDate),
                    ),
                    style: AppTextStyles.caption,
                  ),
                  if (daysLeft != null)
                    Text(
                      daysLeft >= 0
                          ? t.daysLeftPrefix(daysLeft)
                          : t.overduePrefix(daysLeft.abs()),
                      style: AppTextStyles.small.copyWith(
                        color: late
                            ? AppColors.error
                            : (warning ? AppColors.error : AppColors.success),
                      ),
                    ),
                  if (isStaff) _UserLabel(userId: userId),
                ],
              ),
              trailing: isStaff
                  ? OutlinedButton(
                      onPressed: () => AppRoutes.openReturnBook(
                        context,
                        arguments: {'borrowRecordId': doc.id},
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(t.returnAction),
                    )
                  : null,
              onTap: () => _showBorrowDetailSheet(
                context,
                recordId: doc.id,
                bookId: bookId,
                userId: userId,
                borrowDate: borrowDate,
                dueDate: dueDate,
                daysLeft: daysLeft,
                fineAmount: fineAmount,
                processedBy: processedBy,
              ),
            ),
          );
        },
      ),
    );
  }

  static int _daysLeft(DateTime due) {
    final dueDateOnly = DateTime(due.year, due.month, due.day);
    final now = DateTime.now();
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    return dueDateOnly.difference(nowDateOnly).inDays;
  }

  static String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  static void _showBorrowDetailSheet(
    BuildContext context, {
    required String recordId,
    required String bookId,
    required String userId,
    required DateTime? borrowDate,
    required DateTime? dueDate,
    required int? daysLeft,
    required int fineAmount,
    required String processedBy,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BorrowDetailSheet(
        recordId: recordId,
        bookId: bookId,
        userId: userId,
        borrowDate: borrowDate,
        dueDate: dueDate,
        daysLeft: daysLeft,
        fineAmount: fineAmount,
        processedBy: processedBy,
      ),
    );
  }
}

class _BorrowDetailSheet extends StatelessWidget {
  final String recordId;
  final String bookId;
  final String userId;
  final DateTime? borrowDate;
  final DateTime? dueDate;
  final int? daysLeft;
  final int fineAmount;
  final String processedBy;

  const _BorrowDetailSheet({
    required this.recordId,
    required this.bookId,
    required this.userId,
    required this.borrowDate,
    required this.dueDate,
    required this.daysLeft,
    required this.fineAmount,
    required this.processedBy,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final late = daysLeft != null && daysLeft! < 0;
    final warning = daysLeft != null && daysLeft! <= 3;
    final statusColor = late
        ? AppColors.error
        : (warning ? AppColors.warning : AppColors.success);

    String statusText() {
      if (daysLeft == null) return t.statusBorrowing;
      if (daysLeft! >= 0) return t.daysLeftPrefix(daysLeft!);
      return t.overduePrefix(daysLeft!.abs());
    }

    Widget row({required String label, required String value}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Text(
              t.borrowRecordDetailsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.bookLabel, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    _BookTitle(bookId: bookId),
                    const SizedBox(height: 12),
                    Center(
                      child: QrImageView(
                        data: LibraryQrPayload.borrowRecordForReturn(recordId),
                        size: 168,
                        version: QrVersions.auto,
                        gapless: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      'LIB_RET:$recordId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusText(),
                            style: AppTextStyles.small.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          t.borrowSheetFine('$fineAmount'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    row(label: t.ticketIdLabel, value: recordId),
                    row(
                      label: t.borrowDateLabelShort,
                      value: borrowDate == null
                          ? '—'
                          : _CurrentBorrowsScreenState._formatDate(borrowDate!),
                    ),
                    row(
                      label: t.dueDateLabelShort,
                      value: dueDate == null
                          ? '—'
                          : _CurrentBorrowsScreenState._formatDate(dueDate!),
                    ),
                    if (processedBy.trim().isNotEmpty)
                      row(label: t.librarianLabel, value: processedBy),
                  ],
                ),
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
    );
  }
}

class _BookTitle extends StatelessWidget {
  final String bookId;
  const _BookTitle({required this.bookId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (bookId.isEmpty) return Text(t.missingBookId, style: AppTextStyles.h3);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
      builder: (context, snapshot) {
        final title = snapshot.data?.data()?['title']?.toString();
        return Text(
          (title == null || title.isEmpty)
              ? t.bookTitleFallback(bookId)
              : title,
          style: AppTextStyles.h3,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

class _UserLabel extends StatelessWidget {
  final String userId;
  const _UserLabel({required this.userId});

  @override
  Widget build(BuildContext context) {
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
          fullName.isNotEmpty
              ? fullName
              : AppLocalizations.of(context)!.userNamePlaceholder,
          studentCode.isNotEmpty ? studentCode : email,
        ].where((e) => e.isNotEmpty).join(' - ');

        return Text(label, style: AppTextStyles.caption);
      },
    );
  }
}
