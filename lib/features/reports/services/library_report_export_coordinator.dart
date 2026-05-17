import '../../../gen/l10n/app_localizations.dart';
import '../data/library_report_repository.dart';
import '../domain/library_report_bundle.dart';
import 'report_excel_exporter.dart';
import 'report_pdf_exporter.dart';

/// Điều phối nạp dữ liệu ([LibraryReportRepository]) và tạo file Excel/PDF.
///
/// Tách khỏi UI để dễ test / mở rộng thêm CSV, DOCX sau này.
class LibraryReportExportCoordinator {
  LibraryReportExportCoordinator({LibraryReportRepository? repository})
    : _repository = repository ?? LibraryReportRepository();

  final LibraryReportRepository _repository;

  Future<LibraryReportBundle> loadBundle({
    required DateTime start,
    required DateTime end,
    void Function(String phase)? onPhase,
    void Function(int borrowLoaded)? onBorrowProgress,
  }) {
    return _repository.loadFullReport(
      rangeStart: start,
      rangeEnd: end,
      onPhase: onPhase,
      onBorrowProgress: onBorrowProgress,
    );
  }

  Future<List<int>> buildExcelBytes({
    required DateTime start,
    required DateTime end,
    required AppLocalizations l10n,
    void Function(String phase)? onPhase,
    void Function(int borrowLoaded)? onBorrowProgress,
  }) async {
    final bundle = await loadBundle(
      start: start,
      end: end,
      onPhase: onPhase,
      onBorrowProgress: onBorrowProgress,
    );
    return ReportExcelExporter.build(bundle: bundle, l10n: l10n);
  }

  Future<List<int>> buildPdfBytes({
    required DateTime start,
    required DateTime end,
    required AppLocalizations l10n,
    void Function(String phase)? onPhase,
    void Function(int borrowLoaded)? onBorrowProgress,
  }) async {
    final bundle = await loadBundle(
      start: start,
      end: end,
      onPhase: onPhase,
      onBorrowProgress: onBorrowProgress,
    );
    return await ReportPdfExporter.build(bundle: bundle, l10n: l10n);
  }
}
