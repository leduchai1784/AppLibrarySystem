import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/book_cover_from_firestore.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/feature_flags_service.dart';
import '../recommendation/widgets/recommended_books_widget.dart';

/// Trang chủ Sinh viên - Dashboard (theo mockup)
class StudentHomeTab extends StatelessWidget {
  final VoidCallback onGoToHistoryTab;

  const StudentHomeTab({
    super.key,
    required this.onGoToHistoryTab,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StudentRealtimeStatGrid(),

          const SizedBox(height: 14),
          Text(t.quickTasksTitle, style: AppTextStyles.h3),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  label: t.quickLibrary,
                  icon: Icons.menu_book_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.bookList),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionTile(
                  label: t.quickHistoryTab,
                  icon: Icons.history_rounded,
                  onTap: onGoToHistoryTab,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          StreamBuilder<Map<String, bool>>(
            stream: FeatureFlagsService.watchFlags(),
            builder: (context, snap) {
              final flags = snap.data;
              final enabled = FeatureFlagsService.flag(
                flags,
                FeatureFlagsService.aiRecommendationsEnabled,
              );
              if (!enabled) return const SizedBox.shrink();
              return const RecommendedBooksWidget();
            },
          ),

          const SizedBox(height: 20),
          _buildRecentSection(context),
        ],
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('borrow_records');
    if (!AppUser.isStaff && uid != null) {
      query = query.where('userId', isEqualTo: uid);
    }
    query = query.orderBy('borrowDate', descending: true).limit(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.recentBorrowsTitle,
              style: AppTextStyles.h3,
            ),
            TextButton(
              onPressed: onGoToHistoryTab,
              child: Text(t.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text(t.cannotLoadRecentData);
            }

            final docs = snapshot.data?.docs ?? [];
            final items = docs.take(3).toList();
            if (items.isEmpty) {
              return Center(
                child: Text(
                  t.noRecentBorrows,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return Column(
              children: items
                  .map(
                    (d) => _RecentQrCard(
                      recordId: d.id,
                      bookId: (d.data()['bookId'] ?? '') as String,
                      status: (d.data()['status'] ?? 'borrowing') as String,
                      borrowDate: (d.data()['borrowDate'] as Timestamp?)?.toDate(),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Thống kê nhanh đồng bộ Firestore (sách trong kho + phiếu mượn của sinh viên).
class _StudentRealtimeStatGrid extends StatelessWidget {
  const _StudentRealtimeStatGrid();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return SizedBox(
        height: 100,
        child: Center(child: Text(t.needSignInToSeeStats)),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, booksSnap) {
        if (booksSnap.connectionState == ConnectionState.waiting && !booksSnap.hasData) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        }
        final bookDocs = booksSnap.data?.docs ?? [];
        final titleCount = bookDocs.length;
        final categoryCount = bookDocs
            .map((d) {
              final m = d.data();
              return (m['category'] ?? m['categoryId'] ?? '') as String;
            })
            .where((s) => s.trim().isNotEmpty)
            .toSet()
            .length;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('borrow_records').where('userId', isEqualTo: uid).snapshots(),
          builder: (context, borrowsSnap) {
            if (borrowsSnap.connectionState == ConnectionState.waiting && !borrowsSnap.hasData) {
              return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
            }
            final records = borrowsSnap.data?.docs ?? [];
            final active = records.where((d) => (d.data()['status'] ?? '') == 'borrowing').length;
            final now = DateTime.now();
            final startToday = DateTime(now.year, now.month, now.day);
            final endToday = startToday.add(const Duration(days: 1));
            var borrowsToday = 0;
            for (final d in records) {
              final bd = (d.data()['borrowDate'] as Timestamp?)?.toDate();
              if (bd != null && !bd.isBefore(startToday) && bd.isBefore(endToday)) {
                borrowsToday++;
              }
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.02,
              children: [
                _StudentStatTile(
                  title: t.studentHomeStatUniqueTitles,
                  value: '$titleCount',
                  icon: Icons.menu_book_rounded,
                  iconColor: AppColors.primary,
                  badgeText: t.studentHomeStatLibraryStock,
                  badgeColor: AppColors.success,
                ),
                _StudentStatTile(
                  title: t.studentHomeStatActiveBorrows,
                  value: '$active',
                  icon: Icons.bookmark_outline_rounded,
                  iconColor: const Color(0xFF6366F1),
                  badgeText: t.studentHomeStatActiveTickets,
                  badgeColor: const Color(0xFF6366F1),
                ),
                _StudentStatTile(
                  title: t.studentHomeStatCategories,
                  value: '$categoryCount',
                  icon: Icons.folder_outlined,
                  iconColor: AppColors.secondary,
                  badgeText: t.studentHomeStatCategoryKinds,
                  badgeColor: const Color(0xFF94A3B8),
                ),
                _StudentStatTile(
                  title: t.studentHomeStatBorrowedToday,
                  value: '$borrowsToday',
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFFEC4899),
                  badgeText: t.studentHomeStatWithinToday,
                  badgeColor: AppColors.success,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Ô thống kê trong lưới 2×2 — cùng kiểu khung/icon với tab Quản lý.
class _StudentStatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String badgeText;
  final Color badgeColor;

  const _StudentStatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeBg = badgeColor.withValues(alpha: 0.14);
    final badgeFg = badgeColor == const Color(0xFF94A3B8)
        ? theme.colorScheme.onSurfaceVariant
        : badgeColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: badgeFg,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1.05,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        height: 1.25,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.35),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentQrCard extends StatelessWidget {
  final String recordId;
  final String bookId;
  final String status;
  final DateTime? borrowDate;

  const _RecentQrCard({
    required this.recordId,
    required this.bookId,
    required this.status,
    required this.borrowDate,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = switch (status) {
      'late' => AppColors.error,
      'returned' => AppColors.success,
      _ => AppColors.primary,
    };
    final statusLabel = switch (status) {
      'late' => t.statusLate,
      'returned' => t.statusReturned,
      _ => t.statusBorrowing,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (bookId.isEmpty) return;
          Navigator.pushNamed(
            context,
            AppRoutes.bookDetail,
            arguments: {'id': bookId},
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                ),
                child: BookCoverFromBookId(
                  bookId: bookId,
                  width: 44,
                  height: 56,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('books')
                          .doc(bookId)
                          .get(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data();
                        final title = (data?['title'] ?? '').toString();
                        final displayTitle =
                            title.isNotEmpty ? title : t.bookTitleFallback(bookId);
                        return Text(
                          displayTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTextStyles.small.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(borrowDate, t),
                          style: AppTextStyles.small.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.hintColor,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTimeAgo(DateTime? dt, AppLocalizations t) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    final minutes = diff.inMinutes;
    if (minutes < 60) return t.timeAgoMinutes(minutes);
    final hours = diff.inHours;
    if (hours < 24) return t.timeAgoHours(hours);
    final days = diff.inDays;
    return t.timeAgoDays(days);
  }
}
