import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình quản lý người dùng & trạng thái tài khoản (Admin) - UI only
class UserManageScreen extends StatefulWidget {
  const UserManageScreen({super.key});

  @override
  State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  final _searchController = TextEditingController();
  String _filterRole = 'Tất cả';
  final _roles = ['Tất cả', 'Admin', 'Sinh viên'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mockUsers = [
      _UserItem(name: 'Admin 1', email: 'admin@library.vn', role: 'Admin', locked: false),
      _UserItem(name: 'Nguyễn Văn A', email: 'vana@student.vn', role: 'Sinh viên', locked: false),
      _UserItem(name: 'Trần Thị B', email: 'thib@student.vn', role: 'Sinh viên', locked: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên, email...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _roles.map((r) {
                    final selected = _filterRole == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(r),
                        selected: selected,
                        onSelected: (_) => setState(() => _filterRole = r),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockUsers.length,
              itemBuilder: (context, index) {
                final u = mockUsers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: u.locked ? AppColors.error.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                      child: Icon(Icons.person, color: u.locked ? AppColors.error : AppColors.primary),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(u.name, style: AppTextStyles.h3)),
                        if (u.locked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Khóa', style: AppTextStyles.small.copyWith(color: AppColors.error)),
                          ),
                      ],
                    ),
                    subtitle: Text('${u.email} • ${u.role}', style: AppTextStyles.caption),
                    trailing: Switch(
                      value: !u.locked,
                      onChanged: (_) {},
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserItem {
  final String name, email, role;
  final bool locked;
  _UserItem({required this.name, required this.email, required this.role, required this.locked});
}
