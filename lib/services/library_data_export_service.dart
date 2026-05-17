import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_query_limit.dart';
import '../features/reports/services/library_report_export_coordinator.dart';
import '../gen/l10n/app_localizations.dart';

/// Xuất JSON (cài đặt / sao lưu nhỏ) và **ủy quyền** báo cáo Excel/PDF cho [LibraryReportExportCoordinator].
class LibraryDataExportService {
  LibraryDataExportService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final LibraryReportExportCoordinator _reportCoordinator =
      LibraryReportExportCoordinator();

  static dynamic _jsonSafe(dynamic v) {
    if (v is Timestamp) {
      return v.toDate().toUtc().toIso8601String();
    }
    if (v is DocumentReference) {
      return v.path;
    }
    if (v is GeoPoint) {
      return {'latitude': v.latitude, 'longitude': v.longitude};
    }
    if (v is Map) {
      return v.map((k, e) => MapEntry(k.toString(), _jsonSafe(e)));
    }
    if (v is Iterable) {
      return v.map(_jsonSafe).toList();
    }
    return v;
  }

  static Map<String, dynamic> _docJson(String id, Map<String, dynamic> data) {
    final out = <String, dynamic>{'_id': id};
    for (final e in data.entries) {
      out[e.key] = _jsonSafe(e.value);
    }
    return out;
  }

  static Future<String> buildLibraryJsonExport() async {
    final booksSnap = await _db.collection('books').get();
    final categoriesSnap = await _db.collection('categories').get();
    final borrowsSnap = await _db
        .collection('borrow_records')
        .limit(firestoreQueryLimit(5000))
        .get();

    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'version': 1,
      'books': booksSnap.docs.map((d) => _docJson(d.id, d.data())).toList(),
      'categories': categoriesSnap.docs
          .map((d) => _docJson(d.id, d.data()))
          .toList(),
      'borrow_records': borrowsSnap.docs
          .map((d) => _docJson(d.id, d.data()))
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Báo cáo Excel — định tuyến sang [LibraryReportExportCoordinator] + [ReportExcelExporter].
  static Future<List<int>> buildStatisticsExcelBytes({
    required DateTime start,
    required DateTime end,
    required AppLocalizations l10n,
    void Function(String phase)? onPhase,
    void Function(int borrowLoaded)? onBorrowProgress,
  }) async {
    return _reportCoordinator.buildExcelBytes(
      start: start,
      end: end,
      l10n: l10n,
      onPhase: onPhase,
      onBorrowProgress: onBorrowProgress,
    );
  }

  /// Báo cáo PDF — định tuyến sang [LibraryReportExportCoordinator] + [ReportPdfExporter].
  static Future<List<int>> buildStatisticsPdfBytes({
    required DateTime start,
    required DateTime end,
    required AppLocalizations l10n,
    void Function(String phase)? onPhase,
    void Function(int borrowLoaded)? onBorrowProgress,
  }) async {
    return _reportCoordinator.buildPdfBytes(
      start: start,
      end: end,
      l10n: l10n,
      onPhase: onPhase,
      onBorrowProgress: onBorrowProgress,
    );
  }

  static Future<String> buildStudentBorrowsJsonExport(String userId) async {
    final borrowsSnap = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .limit(firestoreQueryLimit(500))
        .get();

    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'version': 1,
      'userId': userId,
      'borrow_records': borrowsSnap.docs
          .map((d) => _docJson(d.id, d.data()))
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
