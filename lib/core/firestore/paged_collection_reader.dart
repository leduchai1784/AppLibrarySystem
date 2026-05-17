import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore_query_limit.dart';

/// Đọc toàn bộ document của một collection bằng nhiều truy vấn có `limit` hợp lệ (≤ [kFirestoreMaxQueryLimit]).
///
/// Dùng `orderBy(FieldPath.documentId)` + [startAfterDocument] — ổn định, không cần index tổng hợp thêm.
class PagedCollectionReader {
  PagedCollectionReader._();

  /// [onBatchLoaded]: số document đã tích lũy sau mỗi batch (tiện báo tiến độ UI).
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchAllOrderedByDocumentId(
    CollectionReference<Map<String, dynamic>> col, {
    int chunkSize = 5000,
    void Function(int totalLoaded)? onBatchLoaded,
  }) async {
    final pageLimit = firestoreQueryLimit(chunkSize);
    final out = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    QueryDocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      var q = col.orderBy(FieldPath.documentId).limit(pageLimit);
      if (cursor != null) {
        q = q.startAfterDocument(cursor);
      }
      final snap = await q.get();
      if (snap.docs.isEmpty) break;
      out.addAll(snap.docs);
      onBatchLoaded?.call(out.length);
      if (snap.docs.length < pageLimit) break;
      cursor = snap.docs.last;
    }
    return out;
  }
}
