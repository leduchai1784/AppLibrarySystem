import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../books/book_list_screen.dart';
import '../dashboard/admin_home_tab.dart';
import '../dashboard/admin_manage_tab.dart';
import '../dashboard/library_settings_tab.dart';
import '../dashboard/scan_book_tab.dart';
import '../web/web_staff_dashboard_shell.dart';
import '../web/web_staff_desk_tab.dart';
import '../../widgets/notification_bell_button.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/feature_flags_service.dart';

/// Dashboard vận hành cho Admin và Quản lý / thủ thư.
/// Tab Cài đặt: tùy chọn ứng dụng + đăng xuất cho mọi nhân sự; cấu hình nâng cao (nếu có) theo quyền trong nội dung tab.
/// **Web:** layout dashboard riêng ([WebStaffDashboardShell]), không theo bottom bar mobile.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  late final bool _showSettingsTab;

  List<_NavItem> _navItems(AppLocalizations t, {required bool scanEnabled}) => [
        _NavItem(Icons.home_outlined, Icons.home, t.tabHome),
        _NavItem(Icons.menu_book_outlined, Icons.menu_book, t.tabBooks),
        if (scanEnabled) _NavItem(Icons.qr_code_scanner, Icons.qr_code_scanner, t.tabScan),
        _NavItem(Icons.manage_search_outlined, Icons.manage_search, t.tabManage),
        _NavItem(Icons.settings_outlined, Icons.settings, t.tabSettings),
      ];

  @override
  void initState() {
    super.initState();
    _showSettingsTab = AppUser.isStaff;
  }

  List<Widget> _buildTabChildren({required bool scanEnabled}) {
    return [
      const AdminHomeTab(),
      const BookListScreen(),
      if (scanEnabled) kIsWeb ? const WebStaffDeskTab() : ScanBookTab(scannerTabActive: _currentIndex == 2),
      const AdminManageTab(),
      if (_showSettingsTab) const LibrarySettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebStaffDashboardShell();
    }

    final theme = Theme.of(context);
    return StreamBuilder<Map<String, bool>>(
      stream: FeatureFlagsService.watchFlags(),
      builder: (context, snap) {
        final flags = snap.data;
        final scanEnabled = FeatureFlagsService.flag(flags, FeatureFlagsService.scanEnabled);
        final tabs = _buildTabChildren(scanEnabled: scanEnabled);
        final nav = _navItems(AppLocalizations.of(context)!, scanEnabled: scanEnabled);

        final maxIndex = (tabs.length - 1).clamp(0, 99);
        final safeIndex = _currentIndex.clamp(0, maxIndex);
        if (safeIndex != _currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _currentIndex = safeIndex);
          });
        }

        return Scaffold(
          appBar: _buildAppBar(scanEnabled: scanEnabled),
          body: IndexedStack(
            index: safeIndex,
            children: tabs,
          ),
          bottomNavigationBar: _buildMobileBottomBar(theme, nav, scanEnabled: scanEnabled),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar({required bool scanEnabled}) {
    final t = AppLocalizations.of(context)!;
    switch (_currentIndex) {
      case 0:
        return AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          title: Text(t.appTitle),
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
        return null;
      case 2:
        if (!scanEnabled) return AppBar(title: Text(t.manageTitle), centerTitle: true);
        return AppBar(
          title: Text(t.scanBookQrTitle),
          centerTitle: true,
        );
      case 3:
        return AppBar(title: Text(t.manageTitle), centerTitle: true);
      case 4:
        if (_showSettingsTab) {
          return AppBar(title: Text(t.settingsTitle), centerTitle: true);
        }
        return AppBar(title: Text(t.appTitle));
      default:
        return AppBar(title: Text(t.appTitle));
    }
  }

  Widget _buildMobileBottomBar(
    ThemeData theme,
    List<_NavItem> nav, {
    required bool scanEnabled,
  }) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const barHeight = 74.0;
    const centerButtonSize = 56.0;

    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ?? Colors.grey;

    if (!scanEnabled) {
      // Không có tab Quét: bottom bar 4 item tiêu chuẩn.
      return SizedBox(
        height: barHeight + bottomPad,
        child: Container(
          height: barHeight + bottomPad,
          padding: EdgeInsets.fromLTRB(14, 10, 14, bottomPad),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomNavItem(
                selected: _currentIndex == 0,
                icon: nav[0].icon,
                activeIcon: nav[0].activeIcon,
                label: nav[0].label,
                color: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _BottomNavItem(
                selected: _currentIndex == 1,
                icon: nav[1].icon,
                activeIcon: nav[1].activeIcon,
                label: nav[1].label,
                color: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _BottomNavItem(
                selected: _currentIndex == 2,
                icon: nav[2].icon,
                activeIcon: nav[2].activeIcon,
                label: nav[2].label,
                color: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              if (_showSettingsTab)
                _BottomNavItem(
                  selected: _currentIndex == 3,
                  icon: nav[3].icon,
                  activeIcon: nav[3].activeIcon,
                  label: nav[3].label,
                  color: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: barHeight + bottomPad,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
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
                    icon: nav[0].icon,
                    activeIcon: nav[0].activeIcon,
                    label: nav[0].label,
                    color: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _BottomNavItem(
                    selected: _currentIndex == 1,
                    icon: nav[1].icon,
                    activeIcon: nav[1].activeIcon,
                    label: nav[1].label,
                    color: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SizedBox(width: centerButtonSize),
                  _BottomNavItem(
                    selected: _currentIndex == 3,
                    icon: nav[3].icon,
                    activeIcon: nav[3].activeIcon,
                    label: nav[3].label,
                    color: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  if (_showSettingsTab)
                    _BottomNavItem(
                      selected: _currentIndex == 4,
                      icon: nav[4].icon,
                      activeIcon: nav[4].activeIcon,
                      label: nav[4].label,
                      color: activeColor,
                      inactiveColor: inactiveColor,
                      onTap: () => setState(() => _currentIndex = 4),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: barHeight + bottomPad - (centerButtonSize / 2),
            child: InkWell(
              onTap: () => setState(() => _currentIndex = 2),
              borderRadius: BorderRadius.circular(centerButtonSize / 2),
              child: Container(
                width: centerButtonSize,
                height: centerButtonSize,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(nav[2].activeIcon, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
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
