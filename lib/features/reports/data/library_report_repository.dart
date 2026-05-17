import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore/paged_collection_reader.dart';
import '../../statistics/library_statistics_engine.dart';
import '../domain/library_report_bundle.dart';

/// Nạp dữ liệu báo cáo thư viện (Firestore) — phiếu / thanh toán phân trang; sách & user vẫn `.get()` (quy mô thư viện điển hình).
///
/// [onPhase]: mô tả giai đoạn (vd: `books`, `borrows`) để UI hiển thị tiến độ.
/// [onBorrowProgress]: số phiếu đã tải khi phân trang `borrow_records`.
class LibraryReportRepository {
  LibraryReportRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<LibraryReportBundle> loadFullReport({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    void Function(String phase)? onPhase,
    void Function(int borrowDocsLoaded)? onBorrowProgress,
  }) async {
    onPhase?.call('books');
    final booksSnap = await _db.collection('books').get();
    onPhase?.call('users');
    final usersSnap = await _db.collection('users').get();
    onPhase?.call('categories');
    final catSnap = await _db.collection('categories').get();
    onPhase?.call('borrows');
    final borrowDocs = await PagedCollectionReader.fetchAllOrderedByDocumentId(
      _db.collection('borrow_records'),
      onBatchLoaded: onBorrowProgress,
    );
    onPhase?.call('payments');
    List<QueryDocumentSnapshot<Map<String, dynamic>>> paymentDocs;
    try {
      paymentDocs = await PagedCollectionReader.fetchAllOrderedByDocumentId(
        _db.collection('payments'),
      );
    } catch (_) {
      paymentDocs = [];
    }
    onPhase?.call('config');
    final cfgSnap = await _db
        .collection('library_settings')
        .doc('config')
        .get();

    onPhase?.call('stats');
    final snapshot = computeLibraryStatistics(
      bookDocs: booksSnap.docs,
      borrowDocsAll: borrowDocs,
      userDocs: usersSnap.docs,
      categoryDocs: catSnap.docs,
      periodStart: rangeStart,
      periodEnd: rangeEnd,
    );

    return LibraryReportBundle(
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      snapshot: snapshot,
      books: booksSnap.docs,
      users: usersSnap.docs,
      categories: catSnap.docs,
      borrowRecords: borrowDocs,
      payments: paymentDocs,
      libraryConfig: cfgSnap.data(),
    );
  }
}
