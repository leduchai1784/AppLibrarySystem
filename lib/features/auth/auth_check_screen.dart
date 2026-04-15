import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // Nếu email chưa được xác thực thì buộc đăng xuất và quay về màn hình đăng nhập
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        await AuthService.signOut();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      await AuthService.reloadUserRole();

      if (!mounted) return;

      if (await AuthService.rejectWebSessionIfNotStaff()) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: const {'staffOnlyWeb': true},
        );
        return;
      }

      if (await AuthService.rejectMobileSessionIfAdmin()) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: const {'adminUseWebOnly': true},
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
