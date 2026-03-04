import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';

/// Màn hình xem thông tin cá nhân (Sinh viên) - UI only
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('Nguyễn Văn A', style: AppTextStyles.h1),
                  Text('SV001', style: AppTextStyles.caption),
                  Text('sinhvien@library.vn', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Sinh viên', style: AppTextStyles.small.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa hồ sơ'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Chuyển sang Admin (dùng thử)'),
                    subtitle: const Text('Chuyển sang giao diện quản trị'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      AppUser.currentRole = UserRole.admin;
                      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('MSSV'),
                    subtitle: const Text('SV001'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Số điện thoại'),
                    subtitle: const Text('0123 456 789'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Địa chỉ'),
                    subtitle: const Text('Ký túc xá B - ĐH Cần Thơ'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
