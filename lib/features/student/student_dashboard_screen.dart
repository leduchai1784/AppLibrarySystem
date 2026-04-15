import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../widgets/notification_bell_button.dart';
import '../borrow/borrow_history_screen.dart';
import '../borrow/current_borrows_screen.dart';
import '../dashboard/library_settings_tab.dart';
import '../dashboard/student_home_tab.dart';

/// Giao diện Dashboard dành riêng cho Sinh viên
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  List<Widget> _buildTabChildren() {
    return [
      StudentHomeTab(
        onGoToHistoryTab: () => setState(() => _currentIndex = 2),
      ),
      const CurrentBorrowsScreen(embedInTab: true),
      const BorrowHistoryScreen(embedInTab: true),
      const LibrarySettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final navItems = [
      _NavItem(Icons.home_outlined, Icons.home, t.tabHome),
      _NavItem(Icons.bookmark_outline, Icons.bookmark, t.tabBorrowing),
      _NavItem(Icons.history, Icons.history, t.tabHistory),
      _NavItem(Icons.settings_outlined, Icons.settings, t.tabSettings),
    ];
    return Scaffold(
      appBar: _buildAppBar(t),
      body: IndexedStack(
        index: _currentIndex,
        children: _buildTabChildren(),
      ),
      bottomNavigationBar: _buildBottomBar(theme, navItems),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations t) {
    switch (_currentIndex) {
      case 0:
        return AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          title: Text(t.studentAppTitle),
          centerTitle: true,
          actions: [
            NotificationBellButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ],
        );
      case 1:
        return AppBar(title: Text(t.borrowedBooksTitle), centerTitle: true);
      case 2:
        return AppBar(
          title: Text(t.borrowHistoryTitle),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          ],
        );
      case 3:
        return AppBar(title: Text(t.settingsTitle), centerTitle: true);
      default:
        return AppBar(title: Text(t.studentAppTitle));
    }
  }

  Widget _buildBottomBar(ThemeData theme, List<_NavItem> navItems) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const barHeight = 74.0;

    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ?? Colors.grey;

    return SizedBox(
      height: barHeight + bottomPad,
      child: Container(
        height: barHeight + bottomPad,
        padding: EdgeInsets.fromLTRB(14, 10, 14, bottomPad),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              selected: _currentIndex == 0,
              icon: navItems[0].icon,
              activeIcon: navItems[0].activeIcon,
              label: navItems[0].label,
              color: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomNavItem(
              selected: _currentIndex == 1,
              icon: navItems[1].icon,
              activeIcon: navItems[1].activeIcon,
              label: navItems[1].label,
              color: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _BottomNavItem(
              selected: _currentIndex == 2,
              icon: navItems[2].icon,
              activeIcon: navItems[2].activeIcon,
              label: navItems[2].label,
              color: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _BottomNavItem(
              selected: _currentIndex == 3,
              icon: navItems[3].icon,
              activeIcon: navItems[3].activeIcon,
              label: navItems[3].label,
              color: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _BottomNavItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconToShow = selected ? activeIcon : icon;
    final itemColor = selected ? color : inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconToShow, color: itemColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
