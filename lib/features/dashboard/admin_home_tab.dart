import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/feature_flags_service.dart';

/// Trang chủ Admin - Thống kê sách
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminRealtimeStatsGrid(),
          const SizedBox(height: 18),
          Text(t.adminQuickTasksTitle, style: AppTextStyles.h3),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, c) {
              final gap = 8.0;
              final w = (c.maxWidth - gap) / 2;
              Widget cell(String label, IconData icon, String route) =>
                  SizedBox(width: w, child: _buildQuickTile(context, label, icon, route));
              return StreamBuilder<Map<String, bool>>(
                stream: FeatureFlagsService.watchFlags(),
                builder: (context, snap) {
                  final flags = snap.data;
                  final borrowEnabled = FeatureFlagsService.flag(flags, FeatureFlagsService.borrowReturnEnabled);
                  final statsEnabled = FeatureFlagsService.flag(flags, FeatureFlagsService.statisticsEnabled);
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      cell(t.adminQuickAddBook, Icons.add_rounded, AppRoutes.addBook),
                      cell(t.adminQuickBookList, Icons.menu_book_outlined, AppRoutes.bookList),
                      if (borrowEnabled)
                        cell(t.adminQuickCreateBorrow, Icons.add_circle_outline, AppRoutes.borrowCreate),
                      if (borrowEnabled) cell(t.adminQuickReturn, Icons.keyboard_return_rounded, AppRoutes.returnBook),
                      cell(t.adminQuickManageCategories, Icons.category_outlined, AppRoutes.categoryManage),
                      if (AppUser.isAdmin) cell(t.adminQuickManageUsers, Icons.people_outline, AppRoutes.userManage),
                      if (statsEnabled) cell(t.adminQuickStats, Icons.bar_chart_rounded, AppRoutes.statistics),
                      if (borrowEnabled) cell(t.adminQuickFinePayment, Icons.payments_outlined, AppRoutes.fine),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickTile(BuildContext context, String label, IconData icon, String route) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (route == AppRoutes.borrowCreate) {
            AppRoutes.openBorrowCreate(context);
          } else if (route == AppRoutes.returnBook) {
            AppRoutes.openReturnBook(context);
          } else {
            AppRoutes.pushRoot(context, route);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

class _AdminRealtimeStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, booksSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, usersSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('borrow_records').snapshots(),
              builder: (context, borrowsSnap) {
                final waiting = booksSnap.connectionState == ConnectionState.waiting &&
                    !booksSnap.hasData &&
                    usersSnap.connectionState == ConnectionState.waiting &&
                    !usersSnap.hasData;
                if (waiting) {
                  return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
                }

                final bookDocs = booksSnap.data?.docs ?? [];
                final titleCount = bookDocs.length;
                final userCount = usersSnap.data?.docs.length ?? 0;
                final borrowDocs = borrowsSnap.data?.docs ?? [];
                final totalBorrows = borrowDocs.length;
                final activeBorrow = borrowDocs.where((d) => (d.data()['status'] ?? '') == 'borrowing').length;

                final stats = [
                  _StatCard(
                    title: t.adminStatBookTitles,
                    value: _formatInt(titleCount),
                    icon: Icons.menu_book_outlined,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    title: t.adminStatUsers,
                    value: _formatInt(userCount),
                    icon: Icons.people_outline,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    title: t.adminStatTotalBorrows,
                    value: _formatInt(totalBorrows),
                    icon: Icons.history_rounded,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    title: t.adminStatActiveBorrow,
                    value: _formatInt(activeBorrow),
                    icon: Icons.bookmark_outline,
                    color: Colors.deepPurple,
                  ),
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: stats.length,
                  itemBuilder: (context, index) {
                    final s = stats[index];
                    final theme = Theme.of(context);
                    final route = switch (index) {
                      0 => AppRoutes.bookList,
                      1 => AppRoutes.userManage,
                      2 => AppRoutes.borrowHistory,
                      _ => AppRoutes.currentBorrows,
                    };
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => AppRoutes.pushRoot(context, route),
                        borderRadius: BorderRadius.circular(14),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.35),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: s.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(s.icon, color: s.color, size: 22),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      s.value,
                                      style: AppTextStyles.h2.copyWith(
                                        fontSize: 20,
                                        height: 1.05,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.title,
                                      style: AppTextStyles.caption.copyWith(fontSize: 12.5, height: 1.2),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
            );
          },
        );
      },
    );
  }

  static String _formatInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatCard {
  final String title, value;
  final IconData icon;
  final Color color;
  _StatCard({required this.title, required this.value, required this.icon, required this.color});
}
