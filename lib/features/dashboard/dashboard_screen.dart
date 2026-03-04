import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../admin/admin_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';

/// Router: Chuyển đến giao diện Admin hoặc Sinh viên dựa trên vai trò
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppUser.isAdmin ? const AdminDashboardScreen() : const StudentDashboardScreen();
  }
}
