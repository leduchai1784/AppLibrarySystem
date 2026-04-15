/// Định dạng QR nội bộ thư viện (in trên phiếu / thẻ sinh viên / tem sách).
///
/// - [returnPrefix]: quét → mở trả sách theo id document `borrow_records`.
/// - [userPrefix]: quét (nhân sự) → form tạo phiếu với sinh viên đã chọn.
/// Sách: QR có thể chỉ là `bookId` hoặc ISBN (như màn chi tiết sách).
class LibraryQrPayload {
  LibraryQrPayload._();

  static const returnPrefix = 'LIB_RET:';
  static const userPrefix = 'LIB_USER:';

  /// Payload in trên phiếu sau khi mượn (thủ thư quét khi trả).
  static String borrowRecordForReturn(String borrowRecordId) => '$returnPrefix$borrowRecordId';

  /// Payload cho sinh viên — thủ thư quét khi lập phiếu.
  static String userForBorrow(String firebaseUid) => '$userPrefix$firebaseUid';
}

/// Kết quả parse một chuỗi quét được.
class LibraryQrParseResult {
  /// Id document `borrow_records` (phiếu đang mượn).
  final String? borrowRecordId;

  /// Firebase uid sinh viên.
  final String? userId;

  /// Tra cứu sách: bookId hoặc ISBN (giữ nguyên nếu không có prefix đặc biệt).
  final String bookLookupKey;

  const LibraryQrParseResult({
    this.borrowRecordId,
    this.userId,
    required this.bookLookupKey,
  });

  static LibraryQrParseResult parse(String raw) {
    final t = raw.trim();
    if (t.startsWith(LibraryQrPayload.returnPrefix)) {
      final id = t.substring(LibraryQrPayload.returnPrefix.length).trim();
      return LibraryQrParseResult(borrowRecordId: id.isEmpty ? null : id, bookLookupKey: '');
    }
    if (t.startsWith(LibraryQrPayload.userPrefix)) {
      final id = t.substring(LibraryQrPayload.userPrefix.length).trim();
      return LibraryQrParseResult(userId: id.isEmpty ? null : id, bookLookupKey: '');
    }
    return LibraryQrParseResult(bookLookupKey: t);
  }
}
