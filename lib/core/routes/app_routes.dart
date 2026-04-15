import 'package:flutter/foundation.dart';
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
import '../../features/admin/audit_log_screen.dart';
import '../../features/admin/library_business_settings_screen.dart';
import '../../features/admin/system_feature_settings_screen.dart';
import '../../features/authors/author_manage_screen.dart';
import '../../features/genres/genre_manage_screen.dart';
import '../../features/stationery/stationery_manage_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/library_settings_tab.dart';
import '../../features/student/student_dashboard_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/users/user_manage_screen.dart';
import '../../features/shared/create_qr_code_screen.dart';
import '../../features/shared/my_qr_screen.dart';
import '../../gen/l10n/app_localizations.dart';

class AppRoutes {
  /// Khóa navigator gốc — dùng khi mở route từ body trong [IndexedStack] (dashboard mobile) để không bị lệch context.
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Dùng cho [RouteAware] (ví dụ [ScanBookTab]): tạm dừng camera tab Quét khi có màn đè như Tạo phiếu mượn.
  static final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

  static const String authCheck = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String createQrCode = '/create-qr-code';

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
  static const String libraryBusinessSettings = '/library-business-settings';
  static const String systemFeatures = '/system-features';
  static const String auditLog = '/audit-log';
  static const String authorManage = '/author-manage';
  static const String genreManage = '/genre-manage';
  static const String stationeryManage = '/stationery-manage';

  // User
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String myQr = '/my-qr';

  /// Mở màn trên [Navigator] gốc của [MaterialApp] (cần khi gọi từ dashboard/IndexedStack hoặc web shell,
  /// tránh route con bị che hoặc nhìn như màn trắng).
  static Future<T?> pushRoot<T extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    final nav = rootNavigatorKey.currentState;
    if (nav != null) {
      return nav.pushNamed<T>(route, arguments: arguments);
    }
    return Navigator.of(context, rootNavigator: true).pushNamed<T>(
      route,
      arguments: arguments,
    );
  }

  /// Mở [BorrowCreateScreen] qua route tường minh — ưu tiên [rootNavigatorKey] (ổn định trên mobile từ tab IndexedStack).
  static Future<T?> pushBorrowCreate<T extends Object?>(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    final route = MaterialPageRoute<T>(
      settings: RouteSettings(
        name: borrowCreate,
        arguments: arguments,
      ),
      builder: (_) => const BorrowCreateScreen(),
    );
    final nav = rootNavigatorKey.currentState;
    if (nav != null) {
      return nav.push<T>(route);
    }
    return Navigator.of(context, rootNavigator: true).push<T>(route);
  }

  /// Shortcut mở màn tạo phiếu mượn.
  ///
  /// Trước đây có trì hoãn `addPostFrameCallback`, nhưng dễ gây cảm giác “bấm không mở” trong một số layout web/mobile.
  /// Nếu cần tránh xung đột khi vừa đóng dialog/bottom sheet, hãy gọi hàm này sau khi pop xong.
  static void openBorrowCreate(BuildContext context, {Map<String, dynamic>? arguments}) {
    if (!context.mounted) return;
    pushBorrowCreate(context, arguments: arguments);
  }

  /// Mở [ReturnScreen] (MaterialPageRoute) — cùng lý do với [pushBorrowCreate].
  static Future<T?> pushReturnBook<T extends Object?>(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    final route = MaterialPageRoute<T>(
      settings: RouteSettings(
        name: returnBook,
        arguments: arguments,
      ),
      builder: (_) => const ReturnScreen(),
    );
    final nav = rootNavigatorKey.currentState;
    if (nav != null) {
      return nav.push<T>(route);
    }
    return Navigator.of(context, rootNavigator: true).push<T>(route);
  }

  static void openReturnBook(BuildContext context, {Map<String, dynamic>? arguments}) {
    if (!context.mounted) return;
    pushReturnBook(context, arguments: arguments);
  }

  static Map<String, WidgetBuilder> get routes => {
        authCheck: (context) => const AuthCheckScreen(),
        login: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final staffDenied = args is Map && args['staffOnlyWeb'] == true;
          final adminWeb = args is Map && args['adminUseWebOnly'] == true;
          return LoginScreen(
            showWebStaffDeniedMessage: staffDenied,
            showAdminUseWebMessage: adminWeb,
          );
        },
        register: (context) => kIsWeb ? const _WebRegisterNotAllowedScreen() : const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        dashboard: (context) => const DashboardScreen(),
        createQrCode: (context) => const CreateQrCodeScreen(),
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
        libraryBusinessSettings: (context) => const LibraryBusinessSettingsScreen(),
        systemFeatures: (context) => const SystemFeatureSettingsScreen(),
        auditLog: (context) => const AuditLogScreen(),
        authorManage: (context) => const AuthorManageScreen(),
        genreManage: (context) => const GenreManageScreen(),
        stationeryManage: (context) => const StationeryManageScreen(),
        profile: (context) => const ProfileScreen(),
        notifications: (context) => const NotificationsScreen(),
        settings: (context) => Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
          body: const LibrarySettingsTab(),
        ),
        myQr: (context) => const MyQrScreen(),
      };

  /// Sau khi xóa sách: đóng màn chi tiết / sửa và về [bookList], rồi hiện SnackBar trên navigator gốc.
  static void finishBookDeletionAndOpenBookList(BuildContext context, {required String message}) {
    final nav = Navigator.of(context, rootNavigator: true);
    String? stoppedName;
    nav.popUntil((route) {
      final stop = route.settings.name == bookList || route.isFirst;
      if (stop) stoppedName = route.settings.name;
      return stop;
    });
    if (stoppedName != bookList) {
      nav.pushNamed(bookList);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
    });
  }
}

/// Đăng ký sinh viên chỉ trên app; web không mở form đăng ký.
class _WebRegisterNotAllowedScreen extends StatelessWidget {
  const _WebRegisterNotAllowedScreen();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.webRegisterNotAllowedTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_android, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  t.webRegisterNotAllowedBody1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  t.webRegisterNotAllowedBody2,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  child: Text(t.backToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
