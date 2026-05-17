import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/firestore_query_limit.dart';

typedef BorrowRecordDoc = QueryDocumentSnapshot<Map<String, dynamic>>;

class BorrowRecordsPage {
  final List<BorrowRecordDoc> docs;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;

  const BorrowRecordsPage({
    required this.docs,
    required this.lastDoc,
    required this.hasMore,
  });
}

/// Repository đọc `borrow_records` — luôn dùng `limit` + cursor, không stream cả collection.
class BorrowRepository {
  BorrowRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const int defaultPageSize = 25;

  Query<Map<String, dynamic>> _historyQuery({
    required String? userIdEquals,
    required String? statusEquals,
  }) {
    Query<Map<String, dynamic>> q = _db.collection('borrow_records');

    // Phiếu đang mượn: orderBy theo hạn trả — dùng composite index ĐÃ CÓ (status + userId + dueDate / status + dueDate),
    // tránh lỗi "missing index" khi orderBy borrowDate + 2 where (index mới có thể chưa deploy).
    if (statusEquals == 'borrowing') {
      if (userIdEquals != null && userIdEquals.isNotEmpty) {
        q = q.where('userId', isEqualTo: userIdEquals);
      }
      q = q.where('status', isEqualTo: 'borrowing');
      return q.orderBy('dueDate', descending: false);
    }

    // Đã trả / trả trễ: orderBy returnDate (đã có khi đóng phiếu) — composite index riêng, không dùng borrowDate+status.
    if (statusEquals == 'returned' || statusEquals == 'late') {
      if (userIdEquals != null && userIdEquals.isNotEmpty) {
        q = q.where('userId', isEqualTo: userIdEquals);
      }
      q = q.where('status', isEqualTo: statusEquals);
      return q.orderBy('returnDate', descending: true);
    }

    if (userIdEquals != null && userIdEquals.isNotEmpty) {
      q = q.where('userId', isEqualTo: userIdEquals);
    }
    return q.orderBy('borrowDate', descending: true);
  }

  /// Lịch sử mượn (sinh viên: [userIdEquals] = uid; nhân sự: `null` = toàn hệ thống).
  /// [statusFilter]: `'all'` = `borrowDate` giảm dần. `'borrowing'` = `dueDate` tăng dần.
  /// `'returned'` / `'late'` = `returnDate` giảm dần (phiếu đã đóng).
  Future<BorrowRecordsPage> fetchHistoryPage({
    required String? userIdEquals,
    String? statusFilter,
    int pageSize = defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final statusEquals =
        (statusFilter == null || statusFilter.isEmpty || statusFilter == 'all')
        ? null
        : statusFilter;
    var q = _historyQuery(
      userIdEquals: userIdEquals,
      statusEquals: statusEquals,
    ).limit(firestoreQueryLimit(pageSize));
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final docs = snap.docs;
    final last = docs.isNotEmpty ? docs.last : startAfter;
    final hasMore = docs.length == pageSize;
    return BorrowRecordsPage(docs: docs, lastDoc: last, hasMore: hasMore);
  }

  Query<Map<String, dynamic>> _activeBorrowsQuery({
    required String? userIdEquals,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection('borrow_records')
        .where('status', isEqualTo: 'borrowing');
    if (userIdEquals != null && userIdEquals.isNotEmpty) {
      q = q.where('userId', isEqualTo: userIdEquals);
    }
    return q.orderBy('dueDate', descending: false);
  }

  /// Phiếu đang mượn — sắp xếp theo hạn trả gần nhất trước.
  Future<BorrowRecordsPage> fetchActiveBorrowsPage({
    required String? userIdEquals,
    int pageSize = defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    var q = _activeBorrowsQuery(
      userIdEquals: userIdEquals,
    ).limit(firestoreQueryLimit(pageSize));
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final docs = snap.docs;
    final last = docs.isNotEmpty ? docs.last : startAfter;
    final hasMore = docs.length == pageSize;
    return BorrowRecordsPage(docs: docs, lastDoc: last, hasMore: hasMore);
  }

  /// `true` nếu user đã có **ít nhất** [maxActive] phiếu `borrowing`.
  /// Chỉ đọc tối đa [maxActive] document (không `.get()` cả tập phiếu — tránh vỡ chi phí khi user mượn nhiều).
  Future<bool> hasActiveBorrowCountAtLeast({
    required String userId,
    required int maxActive,
  }) async {
    final cap = maxActive.clamp(1, 99);
    final snap = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'borrowing')
        .limit(firestoreQueryLimit(cap, max: 99))
        .get();
    return snap.docs.length >= cap;
  }
}
