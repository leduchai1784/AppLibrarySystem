import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';

/// Trang chủ Sinh viên - Tổng quan
class StudentHomeTab extends StatelessWidget {
  const StudentHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sách...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Sách đang mượn',
                  value: '2',
                  icon: Icons.bookmark,
                  color: AppColors.primary,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.currentBorrows),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Đã mượn',
                  value: '12',
                  icon: Icons.history,
                  color: AppColors.success,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.borrowHistory),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Tác vụ nhanh', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickTile(context, 'Sách đang mượn', Icons.bookmark, AppRoutes.currentBorrows),
              _buildQuickTile(context, 'Lịch sử mượn', Icons.history, AppRoutes.borrowHistory),
              _buildQuickTile(context, 'Quét QR sách', Icons.qr_code_scanner, null),
              _buildQuickTile(context, 'Thông báo', Icons.notifications, AppRoutes.notifications),
              _buildQuickTile(context, 'Cài đặt', Icons.settings, AppRoutes.settings),
              _buildQuickTile(context, 'Thanh toán phạt', Icons.payment, AppRoutes.fine),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickTile(BuildContext context, String label, IconData icon, String? route) {
    return InkWell(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
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

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: AppTextStyles.h1.copyWith(fontSize: 22)),
              Text(title, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
