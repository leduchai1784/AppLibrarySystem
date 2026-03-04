import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../borrow/borrow_history_screen.dart';
import '../borrow/current_borrows_screen.dart';
import '../dashboard/library_settings_tab.dart';
import '../dashboard/scan_book_tab.dart';
import '../dashboard/student_home_tab.dart';

/// Giao diện Dashboard dành riêng cho Sinh viên
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    const StudentHomeTab(),
    const CurrentBorrowsScreen(embedInTab: true),
    const ScanBookTab(),
    const BorrowHistoryScreen(embedInTab: true),
    const LibrarySettingsTab(),
  ];

  static const _navItems = [
    _NavItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
    _NavItem(Icons.bookmark_outline, Icons.bookmark, 'Đang mượn'),
    _NavItem(Icons.qr_code_scanner, Icons.qr_code_scanner, 'Quét'),
    _NavItem(Icons.history, Icons.history, 'Lịch sử'),
    _NavItem(Icons.settings_outlined, Icons.settings, 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_currentIndex) {
      case 0:
        return AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          title: const Text('Library System - Sinh viên'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_none),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10))),
                    ),
                  ),
                ],
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ],
        );
      case 1:
        return AppBar(title: const Text('Sách đang mượn'), centerTitle: true);
      case 2:
        return AppBar(title: const Text('Quét QR sách'), centerTitle: true);
      case 3:
        return AppBar(
          title: const Text('Lịch sử mượn'),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          ],
        );
      case 4:
        return AppBar(title: const Text('Cài đặt'), centerTitle: true);
      default:
        return AppBar(title: const Text('Library System - Sinh viên'));
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
