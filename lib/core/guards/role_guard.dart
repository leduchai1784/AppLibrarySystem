import '../constants/app_constants.dart';

/// Kiểm tra quyền theo role — bọc [AppUser] để màn hình/feature gọi một chỗ, dễ test/mở rộng.
class RoleGuard {
  RoleGuard._();

  static bool get isAdmin => AppUser.isAdmin;
  static bool get isManager => AppUser.isManager;
  static bool get isStudent => AppUser.isStudent;
  static bool get isStaff => AppUser.isStaff;

  static bool hasAnyStaffRole() => AppUser.isStaff;

  static bool hasAdminRole() => AppUser.isAdmin;
}
