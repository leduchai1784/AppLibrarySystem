import 'package:flutter/material.dart';

import '../../features/auth/auth_check_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/books/add_edit_book_screen.dart';
import '../../features/books/book_detail_screen.dart';
import '../../features/books/book_list_screen.dart';
import '../../features/borrow/borrow_create_screen.dart';
import '../../features/borrow/borrow_history_screen.dart';
import '../../features/borrow/current_borrows_screen.dart';
import '../../features/borrow/fine_screen.dart';
import '../../features/borrow/return_screen.dart';
import '../../features/categories/category_manage_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/library_settings_tab.dart';
import '../../features/student/student_dashboard_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/users/user_manage_screen.dart';

class AppRoutes {
  static const String authCheck = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';

  // Dashboard theo vai trò (tách riêng để dễ kiểm soát)
  static const String adminDashboard = '/admin-dashboard';
  static const String studentDashboard = '/student-dashboard';

  // Books
  static const String bookList = '/book-list';
  static const String bookDetail = '/book-detail';
  static const String addBook = '/add-book';
  static const String editBook = '/edit-book';

  // Borrow
  static const String borrowCreate = '/borrow-create';
  static const String returnBook = '/return-book';
  static const String borrowHistory = '/borrow-history';
  static const String currentBorrows = '/current-borrows';
  static const String fine = '/fine';

  // Admin
  static const String categoryManage = '/category-manage';
  static const String userManage = '/user-manage';
  static const String statistics = '/statistics';

  // User
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        authCheck: (context) => const AuthCheckScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        dashboard: (context) => const DashboardScreen(),
        adminDashboard: (context) => const AdminDashboardScreen(),
        studentDashboard: (context) => const StudentDashboardScreen(),
        bookList: (context) => const BookListScreen(),
        bookDetail: (context) => const BookDetailScreen(),
        addBook: (context) => const AddEditBookScreen(isEdit: false),
        editBook: (context) => const AddEditBookScreen(isEdit: true),
        borrowCreate: (context) => const BorrowCreateScreen(),
        returnBook: (context) => const ReturnScreen(),
        borrowHistory: (context) => const BorrowHistoryScreen(),
        currentBorrows: (context) => const CurrentBorrowsScreen(),
        fine: (context) => const FineScreen(),
        categoryManage: (context) => const CategoryManageScreen(),
        userManage: (context) => const UserManageScreen(),
        statistics: (context) => const StatisticsScreen(),
        profile: (context) => const ProfileScreen(),
        notifications: (context) => const NotificationsScreen(),
        settings: (context) => Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: const LibrarySettingsTab(),
        ),
      };
}
