import 'package:flutter/material.dart';

import '../../core/guards/auth_guard.dart';
import '../../core/guards/session_block_reason.dart';
import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';

/// Màn hình kiểm tra trạng thái đăng nhập khi mở app
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final user = AuthService.currentUser;
    if (user != null) {
      final emailBlock = AuthGuard.validateEmailVerified(user);
      if (emailBlock != null) {
        await AuthService.signOut();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      await AuthService.reloadUserRole();

      if (!mounted) return;

      final platformBlock = await AuthService.signOutIfPlatformAccessDenied();
      if (platformBlock != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: platformBlock.loginRouteArguments,
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
