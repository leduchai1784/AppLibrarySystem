import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';

/// Tab Cài đặt - giao diện hoàn chỉnh cho Admin và Sinh viên
class LibrarySettingsTab extends StatelessWidget {
  const LibrarySettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Phần thông tin tài khoản
        _buildProfileHeader(context),
        const SizedBox(height: 24),

        // Ứng dụng
        _SectionHeader(title: 'Ứng dụng'),
        SwitchListTile(
          title: const Text('Giao diện tối'),
          subtitle: const Text('Bật/tắt chế độ tối'),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          title: const Text('Ngôn ngữ'),
          subtitle: const Text('Tiếng Việt'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        SwitchListTile(
          title: const Text('Thông báo'),
          subtitle: const Text('Nhắc nhở sắp đến hạn trả sách'),
          value: true,
          onChanged: (_) {},
        ),
        ListTile(
          title: const Text('Thông báo chi tiết'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),

        // Tài khoản
        const SizedBox(height: 12),
        _SectionHeader(title: 'Tài khoản'),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Xem hồ sơ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        ),
        if (AppUser.isAdmin)
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Quản lý người dùng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.userManage),
          ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('Chuyển vai trò'),
          subtitle: Text(AppUser.isAdmin ? 'Hiện: Admin' : 'Hiện: Sinh viên'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            AppUser.currentRole = AppUser.isAdmin ? UserRole.student : UserRole.admin;
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          },
        ),

        // Bảo mật
        const SizedBox(height: 12),
        _SectionHeader(title: 'Bảo mật'),
        SwitchListTile(
          title: const Text('Khóa ứng dụng'),
          subtitle: const Text('Yêu cầu mật khẩu khi mở app'),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          leading: const Icon(Icons.pin_outlined),
          title: const Text('Mã PIN'),
          subtitle: const Text('Thiết lập mã PIN'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        SwitchListTile(
          title: const Text('Face ID / vân tay'),
          subtitle: const Text('Đăng nhập sinh trắc học'),
          value: false,
          onChanged: (_) {},
        ),

        // Dữ liệu
        const SizedBox(height: 12),
        _SectionHeader(title: 'Dữ liệu'),
        SwitchListTile(
          title: const Text('Sao lưu tự động'),
          subtitle: const Text('Lần cuối: Chưa sao lưu'),
          value: false,
          onChanged: (_) {},
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Khôi phục dữ liệu'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Xuất dữ liệu'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.delete_outline, color: AppColors.error),
          title: Text(
            'Xóa cache',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),

        // Về ứng dụng
        const SizedBox(height: 12),
        _SectionHeader(title: 'Về ứng dụng'),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Phiên bản'),
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text('Hướng dẫn sử dụng'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Điều khoản sử dụng'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Chính sách bảo mật'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.star_outline),
          title: const Text('Đánh giá ứng dụng'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (_) => Icon(Icons.star_border, size: 20, color: theme.colorScheme.primary)),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.contact_support_outlined),
          title: const Text('Liên hệ hỗ trợ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: const Text('ĐĂNG XUẤT'),
          ),
        ),
        const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              AppUser.isAdmin ? 'Quản trị viên' : 'Người dùng Library',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 4),
            Text(
              AppUser.isAdmin ? 'admin@library.vn' : 'user@example.com',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Hồ sơ'),
                  ),
                  if (AppUser.isAdmin)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.userManage),
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('Quản lý'),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 12),
      child: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
