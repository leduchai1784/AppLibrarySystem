import 'package:flutter/services.dart';

/// Tên file báo cáo: `library_report_YYYY_MM_DD.xlsx` / `.pdf`
class ReportFileNaming {
  ReportFileNaming._();

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String libraryReportExcel(DateTime d) =>
      'library_report_${d.year}_${_two(d.month)}_${_two(d.day)}.xlsx';

  static String libraryReportPdf(DateTime d) =>
      'library_report_${d.year}_${_two(d.month)}_${_two(d.day)}.pdf';
}

/// Logo ứng dụng (assets) — dùng cho PDF.
Future<ByteData> loadAppLogoBytes() => rootBundle.load('logolibrarysystem.png');
