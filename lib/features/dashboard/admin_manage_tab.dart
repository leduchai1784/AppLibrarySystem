import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';

/// Tab quản lý (Admin) - Danh mục, người dùng, thống kê
class AdminManageTab extends StatelessWidget {
  const AdminManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem('Quản lý danh mục sách', Icons.category, AppRoutes.categoryManage),
      _MenuItem('Quản lý người dùng', Icons.people, AppRoutes.userManage),
      _MenuItem('Thống kê & báo cáo', Icons.bar_chart, AppRoutes.statistics),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: menuItems
            .map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(m.icon, color: AppColors.primary),
                    ),
                    title: Text(m.title, style: AppTextStyles.h3),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, m.route),
                  ),
                ))
            .toList(),
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
