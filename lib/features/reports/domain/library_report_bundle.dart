import 'package:cloud_firestore/cloud_firestore.dart';

import '../../statistics/library_statistics_engine.dart';

/// Snapshot đã nạp + thống kê tính sẵn — đầu vào cho Excel/PDF export.
class LibraryReportBundle {
  const LibraryReportBundle({
    required this.rangeStart,
    required this.rangeEnd,
    required this.snapshot,
    required this.books,
    required this.users,
    required this.categories,
    required this.borrowRecords,
    required this.payments,
    this.libraryConfig,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final LibraryStatisticsSnapshot snapshot;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> books;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> users;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> categories;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> borrowRecords;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> payments;
  final Map<String, dynamic>? libraryConfig;
}
