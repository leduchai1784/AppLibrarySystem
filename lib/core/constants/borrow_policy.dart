/// Quy tắc thời hạn mượn (đồng bộ UI + quét nhanh + service khi chỉ có số ngày).
abstract final class BorrowPolicy {
  /// Ít nhất 3 ngày mượn (hạn trả cách ngày mượn tối thiểu 3 ngày).
  static const int minLoanDays = 3;

  /// Tối đa 30 ngày.
  static const int maxLoanDays = 30;

  /// Khoảng gợi ý mặc định khi đọc `library_settings/config.loanDays` (7–14).
  static const int suggestedMinDays = 7;
  static const int suggestedMaxDays = 14;

  /// Mặc định khi không có cấu hình (nằm trong [suggestedMinDays, suggestedMaxDays]).
  static const int defaultLoanDays = 14;

  static int clampToLoanRange(int days) =>
      days.clamp(minLoanDays, maxLoanDays);

  /// Giá trị gợi ý từ Firestore: đưa về [7, 14] để làm ngày trả ban đầu trên form.
  static int clampConfigToSuggestedRange(int days) =>
      days.clamp(suggestedMinDays, suggestedMaxDays);
}
