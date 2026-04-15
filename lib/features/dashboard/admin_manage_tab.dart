import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';

/// Tab quản lý — mượn/trả, danh mục, người dùng, thống kê
class AdminManageTab extends StatelessWidget {
  const AdminManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final menuItems = <_MenuItem>[
      // Web: đã có lối tắt ở Tổng quan + Quầy làm việc — tránh lặp trong Vận hành.
      if (AppUser.isStaff && !kIsWeb)
        _MenuItem(t.manageCurrentBorrows, Icons.bookmark_outline_rounded, AppRoutes.currentBorrows),
      if (AppUser.isStaff && !kIsWeb)
        _MenuItem(t.manageBorrowHistory, Icons.history_rounded, AppRoutes.borrowHistory),
      _MenuItem(t.manageCategoryManage, Icons.category_outlined, AppRoutes.categoryManage),
      if (AppUser.isStaff) _MenuItem(t.manageAuthors, Icons.person_search_outlined, AppRoutes.authorManage),
      if (AppUser.isStaff) _MenuItem(t.manageGenres, Icons.label_outline_rounded, AppRoutes.genreManage),
      if (AppUser.isStaff) _MenuItem(t.manageStationery, Icons.inventory_2_outlined, AppRoutes.stationeryManage),
      if (AppUser.isAdmin) _MenuItem(t.manageUserManage, Icons.people_outline, AppRoutes.userManage),
      if (AppUser.isAdmin) _MenuItem(t.manageLibraryConfig, Icons.tune_rounded, AppRoutes.libraryBusinessSettings),
      if (AppUser.isAdmin) _MenuItem(t.systemFeaturesTitle, Icons.toggle_on_rounded, AppRoutes.systemFeatures),
      if (AppUser.isAdmin) _MenuItem(t.manageAuditLog, Icons.history_edu_outlined, AppRoutes.auditLog),
      _MenuItem(t.manageStatsReports, Icons.bar_chart_rounded, AppRoutes.statistics),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppUser.isStaff && !kIsWeb) ...[
            _ManageLinkTile(
              theme: theme,
              icon: Icons.add_circle_outline_rounded,
              iconColor: AppColors.primary,
              title: t.manageCreateBorrow,
              subtitle: t.manageCreateBorrowSubtitle,
              onTap: () => AppRoutes.openBorrowCreate(context),
            ),
            const SizedBox(height: 6),
            _ManageLinkTile(
              theme: theme,
              icon: Icons.keyboard_return_rounded,
              iconColor: AppColors.success,
              title: t.manageReturnBook,
              subtitle: t.manageReturnBookSubtitle,
              onTap: () => AppRoutes.openReturnBook(context),
            ),
            const SizedBox(height: 8),
          ],
          ...menuItems.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _ManageLinkTile(
                theme: theme,
                icon: m.icon,
                iconColor: AppColors.primary,
                title: m.title,
                onTap: () => AppRoutes.pushRoot(context, m.route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageLinkTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ManageLinkTile({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: subtitle != null ? 10 : 9),
          child: Row(
            crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 12.5,
                          height: 1.25,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: subtitle != null ? 1 : 0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;
  _MenuItem(this.title, this.icon, this.route);
}
