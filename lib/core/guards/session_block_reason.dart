/// Lý do chặn phiên sau khi đã có Firebase user (điều hướng / SnackBar thống nhất).
enum SessionBlockReason {
  /// Email chưa xác thực — client phải đăng xuất và yêu cầu xác thực.
  emailNotVerified,

  /// Web chỉ dành cho admin/manager.
  webRequiresStaff,

  /// Admin không dùng app mobile.
  mobileAdminRequiresWeb,
}

extension SessionBlockReasonNavigation on SessionBlockReason {
  /// Tham số route [AppRoutes.login] (đồng bộ với [AppRoutes.routes] hiện tại).
  Map<String, dynamic>? get loginRouteArguments {
    switch (this) {
      case SessionBlockReason.emailNotVerified:
        return null;
      case SessionBlockReason.webRequiresStaff:
        return const {'staffOnlyWeb': true};
      case SessionBlockReason.mobileAdminRequiresWeb:
        return const {'adminUseWebOnly': true};
    }
  }
}
