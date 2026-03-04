import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';

/// Trang chủ Admin - Thống kê sách
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCard(title: 'Tổng số sách', value: '1.250', icon: Icons.menu_book, color: AppColors.primary),
      _StatCard(title: 'Tổng người dùng', value: '320', icon: Icons.people, color: AppColors.secondary),
      _StatCard(title: 'Tổng lượt mượn', value: '5.840', icon: Icons.history, color: AppColors.success),
      _StatCard(title: 'Sách đang mượn', value: '156', icon: Icons.bookmark, color: Colors.deepPurple),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sách, người dùng...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final s = stats[index];
              return Card(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, color: s.color, size: 28),
                        const SizedBox(height: 8),
                        Text(s.value, style: AppTextStyles.h2),
                        Text(s.title, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Tác vụ nhanh', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickTile(context, 'Thêm sách', Icons.add, AppRoutes.addBook),
              _buildQuickTile(context, 'Danh sách sách', Icons.menu_book, AppRoutes.bookList),
              _buildQuickTile(context, 'Tạo phiếu mượn', Icons.add_circle, AppRoutes.borrowCreate),
              _buildQuickTile(context, 'Trả sách', Icons.keyboard_return, AppRoutes.returnBook),
              _buildQuickTile(context, 'Quản lý danh mục', Icons.category, AppRoutes.categoryManage),
              _buildQuickTile(context, 'Quản lý người dùng', Icons.people, AppRoutes.userManage),
              _buildQuickTile(context, 'Thống kê', Icons.bar_chart, AppRoutes.statistics),
              _buildQuickTile(context, 'Thanh toán phạt', Icons.payment, AppRoutes.fine),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickTile(BuildContext context, String label, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _StatCard {
  final String title, value;
  final IconData icon;
  final Color color;
  _StatCard({required this.title, required this.value, required this.icon, required this.color});
}
