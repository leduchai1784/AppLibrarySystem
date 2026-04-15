import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';

/// Router: portal nhân viên (admin/manager) hoặc sinh viên
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && AppUser.isStudent) {
      return const _WebStaffOnlyGate();
    }
    if (!kIsWeb && AppUser.isAdmin) {
      return const _MobileAdminUseWebGate();
    }
    return AppUser.isStaff ? const AdminDashboardScreen() : const StudentDashboardScreen();
  }
}

/// Admin chỉ dùng web; app mobile dành cho quản lý & sinh viên.
class _MobileAdminUseWebGate extends StatelessWidget {
  const _MobileAdminUseWebGate();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 56, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    t.adminUseWebTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.adminUseWebBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () async {
                      await AuthService.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    },
                    child: Text(t.commonSignOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trình duyệt chỉ dùng cho quản trị / quản lý; sinh viên dùng app mobile.
class _WebStaffOnlyGate extends StatelessWidget {
  const _WebStaffOnlyGate();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  t.webStaffOnlyTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  t.webStaffOnlyBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  child: Text(t.commonSignOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
