/// Vai trò người dùng trong hệ thống thư viện
enum UserRole {
  admin,
  student,
}

/// Quản lý role hiện tại và phiên đăng nhập
class AppUser {
  static UserRole currentRole = UserRole.student;

  static bool get isAdmin => currentRole == UserRole.admin;
  static bool get isStudent => currentRole == UserRole.student;

  /// Cập nhật role sau khi đăng nhập
  static void setRole(UserRole role) {
    currentRole = role;
  }

  /// Xóa thông tin phiên khi đăng xuất
  static void clear() {
    currentRole = UserRole.student;
  }
}
