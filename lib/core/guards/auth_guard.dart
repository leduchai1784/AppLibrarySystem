import 'package:firebase_auth/firebase_auth.dart';

import 'session_block_reason.dart';

/// Rà soát phiên Firebase Auth (không phụ thuộc Firestore role).
class AuthGuard {
  AuthGuard._();

  /// Trả về [SessionBlockReason.emailNotVerified] nếu cần chặn đăng nhập.
  static SessionBlockReason? validateEmailVerified(User user) {
    if (user.emailVerified) return null;
    return SessionBlockReason.emailNotVerified;
  }
}
