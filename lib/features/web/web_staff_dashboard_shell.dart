import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../gen/l10n/app_localizations.dart';
import '../books/book_list_screen.dart';
import '../dashboard/admin_manage_tab.dart';
import 'web_staff_desk_tab.dart';
import 'web_staff_home_page.dart';
import 'web_system_config_page.dart';

/// Layout dashboard web riêng: sidebar tối, vùng làm việc sáng, header ngữ cảnh — không theo pattern bottom bar mobile.
class WebStaffDashboardShell extends StatefulWidget {
  const WebStaffDashboardShell({super.key});

  @override
  State<WebStaffDashboardShell> createState() => _WebStaffDashboardShellState();
}

class _WebSection {
  final String title;
  final IconData icon;
  final IconData iconSelected;
  final Widget page;

  /// Trang đã có AppBar riêng (vd. danh sách sách) — ẩn header của shell.
  final bool hideTopChrome;

  const _WebSection({
    required this.title,
    required this.icon,
    required this.iconSelected,
    required this.page,
    this.hideTopChrome = false,
  });
}

class _WebStaffDashboardShellState extends State<WebStaffDashboardShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selected = 0;

  static const Color _sidebarBg = Color(0xFF0F172A);
  static const Color _canvasBg = Color(0xFFF1F5F9);

  /// Luôn tính lại theo [AppUser] hiện tại — tránh lỗi cũ: [initState] chạy khi role chưa kịp nạp
  /// → thiếu mục “Cấu hình hệ thống” dù Firestore sau đó là admin.
  List<_WebSection> _buildSections() {
    final t = AppLocalizations.of(context)!;
    return [
      _WebSection(
        title: t.webSectionOverview,
        icon: Icons.dashboard_outlined,
        iconSelected: Icons.dashboard,
        page: const WebStaffHomePage(),
      ),
      _WebSection(
        title: t.webSectionInventory,
        icon: Icons.menu_book_outlined,
        iconSelected: Icons.menu_book,
        hideTopChrome: true,
        page: const BookListScreen(),
      ),
      _WebSection(
        title: t.webSectionDesk,
        icon: Icons.edit_note_outlined,
        iconSelected: Icons.edit_note,
        page: const WebStaffDeskTab(),
      ),
      _WebSection(
        title: t.webSectionOperations,
        icon: Icons.tune_outlined,
        iconSelected: Icons.tune,
        page: const AdminManageTab(),
      ),
      if (AppUser.isStaff)
        _WebSection(
          title: t.webSectionSystemConfig,
          icon: Icons.settings_outlined,
          iconSelected: Icons.settings,
          page: const WebSystemConfigPage(),
        ),
    ];
  }

  List<Widget> _trailingActions(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? t.webStaffAccountFallback;

    return [
      IconButton(
        tooltip: t.webNotificationsTooltip,
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => AppRoutes.pushRoot(context, AppRoutes.notifications),
      ),
      PopupMenuButton<String>(
        offset: const Offset(0, 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        onSelected: (v) async {
          if (v == 'profile') {
            if (context.mounted) AppRoutes.pushRoot(context, AppRoutes.profile);
          }
          if (v == 'out') {
            await AuthService.signOut();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'profile', child: Text(t.webMenuProfile)),
          PopupMenuItem(value: 'out', child: Text(t.webMenuSignOut)),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _sidebar({
    required List<_WebSection> sections,
    required void Function(int) onSelect,
  }) {
    final t = AppLocalizations.of(context)!;
    return ColoredBox(
      color: _sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 16, 28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_library, color: Color(0xFF38BDF8), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.appTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          t.webControlCenter,
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                itemCount: sections.length,
                itemBuilder: (context, i) {
                  final s = sections[i];
                  final sel = _selected == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: sel ? const Color(0xFF1D4ED8).withValues(alpha: 0.45) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(
                          sel ? s.iconSelected : s.icon,
                          color: sel ? Colors.white : Colors.white70,
                        ),
                        title: Text(
                          s.title,
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.white70,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14.5,
                          ),
                        ),
                        selected: sel,
                        onTap: () => onSelect(i),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        hoverColor: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0x33FFFFFF)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white54),
              title: Text(t.webMenuSignOut, style: const TextStyle(color: Colors.white70)),
              onTap: () async {
                await AuthService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();
    final safeIndex = sections.isEmpty
        ? 0
        : _selected.clamp(0, sections.length - 1);
    if (safeIndex != _selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selected = safeIndex);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 960;

        if (narrow) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: _canvasBg,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: Text(sections[safeIndex].title),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: _trailingActions(context),
            ),
            drawer: Drawer(
              width: 288,
              child: _sidebar(
                sections: sections,
                onSelect: (i) {
                  setState(() => _selected = i);
                  Navigator.pop(context);
                },
              ),
            ),
            body: IndexedStack(
              index: safeIndex,
              children: sections.map((s) => s.page).toList(),
            ),
          );
        }

        final showTop = !sections[safeIndex].hideTopChrome;

        return Scaffold(
          backgroundColor: _canvasBg,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 272,
                child: _sidebar(
                  sections: sections,
                  onSelect: (i) => setState(() => _selected = i),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showTop)
                      _WebTopBar(
                        title: sections[safeIndex].title,
                        actions: _trailingActions(context),
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: safeIndex,
                        children: sections.map((s) => s.page).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WebTopBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const _WebTopBar({
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.45)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const Spacer(),
            ...actions,
          ],
        ),
      ),
    );
  }
}
