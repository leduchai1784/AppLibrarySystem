/// Vai trò người dùng trong hệ thống thư viện
/// Giá trị lưu Firestore `users.role`: `admin` | `manager` | `student`
enum UserRole {
  admin,
  manager,
  student,
}

/// Giá trị `category` mặc định trên Firestore khi không gán (đồng bộ với thống kê / lọc).
const String kDefaultBookCategory = 'Khác';

/// Quản lý role hiện tại và phiên đăng nhập
class AppUser {
  static UserRole currentRole = UserRole.student;

  static bool get isAdmin => currentRole == UserRole.admin;
  static bool get isManager => currentRole == UserRole.manager;
  static bool get isStudent => currentRole == UserRole.student;

  /// Admin hoặc quản lý / thủ thư — dùng chung portal vận hành
  static bool get isStaff => isAdmin || isManager;

  /// Cập nhật role sau khi đăng nhập
  static void setRole(UserRole role) {
    currentRole = role;
  }

  /// Xóa thông tin phiên khi đăng xuất
  static void clear() {
    currentRole = UserRole.student;
  }
}
