import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'session_block_reason.dart';

/// Chính sách truy cập theo nền tảng (web vs mobile) và vai trò đã nạp trong [AppUser].
class PlatformGuard {
  PlatformGuard._();

  /// `null` nếu được phép ở nền tảng hiện tại với role hiện tại.
  static SessionBlockReason? evaluateAccessForCurrentPlatform() {
    if (kIsWeb && AppUser.isStudent) {
      return SessionBlockReason.webRequiresStaff;
    }
    if (!kIsWeb && AppUser.isAdmin) {
      return SessionBlockReason.mobileAdminRequiresWeb;
    }
    return null;
  }

  /// Dashboard: hiển thị gate thay vì dashboard đầy đủ (không đăng xuất — phòng trường hợp role/platform lệch tạm thời).
  static bool shouldShowWebStudentGate() => kIsWeb && AppUser.isStudent;

  static bool shouldShowMobileAdminGate() => !kIsWeb && AppUser.isAdmin;
}
