/// Giới hạn cứng của Firestore cho một structured query: [Query.limit] tối đa **10_000**.
/// Vượt quá sẽ gặp `invalid-argument: Limit value ... is over the maximum value of 10000`.
const int kFirestoreMaxQueryLimit = 10000;

/// Chuẩn hóa [value] trước khi truyền vào [Query.limit].
///
/// - [max] mặc định bằng [kFirestoreMaxQueryLimit], không được > 10_000.
/// - [ifNonPositive]: khi [value] <= 0 (dùng khi tính động sai), trả về giá trị an toàn trong \[1, max].
int firestoreQueryLimit(
  int value, {
  int max = kFirestoreMaxQueryLimit,
  int ifNonPositive = 20,
}) {
  assert(
    max >= 1 && max <= kFirestoreMaxQueryLimit,
    'max must be 1..$kFirestoreMaxQueryLimit',
  );
  final cap = max;
  if (value <= 0) {
    return ifNonPositive.clamp(1, cap);
  }
  return value > cap ? cap : value;
}

/// Alias theo convention dự án — [max] không vượt quá giới hạn Firestore.
int safeLimit(int value, {int max = 1000, int ifNonPositive = 20}) {
  final m = max.clamp(1, kFirestoreMaxQueryLimit);
  return firestoreQueryLimit(value, max: m, ifNonPositive: ifNonPositive);
}
