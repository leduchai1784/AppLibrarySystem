import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../domain/library_report_bundle.dart';

/// Xuất PDF A4, font Noto (Unicode tiếng Việt), logo app, số trang.
class ReportPdfExporter {
  ReportPdfExporter._();

  static bool _borrowInPeriod(
    QueryDocumentSnapshot<Map<String, dynamic>> d,
    DateTime start,
    DateTime endInclusive,
  ) {
    final bd = (d.data()['borrowDate'] as Timestamp?)?.toDate();
    if (bd == null) return false;
    final day = DateTime(bd.year, bd.month, bd.day);
    final a = DateTime(start.year, start.month, start.day);
    final b = DateTime(endInclusive.year, endInclusive.month, endInclusive.day);
    return !day.isBefore(a) && !day.isAfter(b);
  }

  static String _fmtRange(DateTime start, DateTime end) {
    String f(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${f(start)} — ${f(end)}';
  }

  static String _ts(dynamic v) {
    if (v is Timestamp) return v.toDate().toLocal().toString().split('.').first;
    return '';
  }

  static Future<List<int>> build({
    required LibraryReportBundle bundle,
    required AppLocalizations l10n,
  }) async {
    final snap = bundle.snapshot;
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pw.ImageProvider? logo;
    try {
      final data = await rootBundle.load('logolibrarysystem.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    final periodBorrows = bundle.borrowRecords
        .where((d) => _borrowInPeriod(d, bundle.rangeStart, bundle.rangeEnd))
        .toList();
    const pdfBorrowCap = 1200;
    final borrowRows = <List<String>>[];
    for (var i = 0; i < periodBorrows.length && i < pdfBorrowCap; i++) {
      final d = periodBorrows[i];
      final m = d.data();
      borrowRows.add([
        d.id,
        '${m['bookId'] ?? ''}',
        '${m['userId'] ?? ''}',
        '${m['status'] ?? ''}',
        _ts(m['borrowDate']),
        _ts(m['dueDate']),
        _ts(m['returnDate']),
      ]);
    }

    final topRows = snap.topBorrowed
        .map((e) => ['${e.rank}', e.title, e.categoryLabel, '${e.borrowCount}'])
        .toList();
    final exportedAt = DateTime.now().toLocal().toString().split('.').first;

    final paymentRows = <List<String>>[];
    const payCap = 400;
    for (var i = 0; i < bundle.payments.length && i < payCap; i++) {
      final d = bundle.payments[i];
      final m = d.data();
      paymentRows.add([
        d.id,
        '${m['userId'] ?? ''}',
        '${m['amount'] ?? ''}',
        '${m['method'] ?? ''}',
        _ts(m['createdAt']),
      ]);
    }

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 48, 40, 52),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null) pw.Image(logo, width: 42, height: 42),
                if (logo != null) pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        l10n.exportStatReportTitlePdf,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        l10n.exportStatDateRange(
                          _fmtRange(bundle.rangeStart, bundle.rangeEnd),
                        ),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        l10n.exportStatExportedAt(exportedAt),
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.8, color: PdfColors.blueGrey300),
          ],
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            'Trang ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700),
          ),
        ),
        build: (ctx) => [
          pw.Text(
            l10n.statsOverviewSection,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: [l10n.exportStatMetric, l10n.exportStatValue],
            data: <List<String>>[
              [l10n.exportStatBookTitlesCount, '${snap.totalBookTitles}'],
              [l10n.exportStatTotalUsers, '${snap.totalUsers}'],
              [l10n.exportStatTotalCopiesQty, '${snap.totalBookCopies}'],
              [
                l10n.exportStatTotalAvailableStock,
                '${snap.totalAvailableCopies}',
              ],
              [l10n.statsCardBorrowTurnsPeriod, '${snap.borrowEventsInPeriod}'],
              [
                l10n.exportStatActiveTicketsSystemWide,
                '${snap.activeBorrowTicketsGlobal}',
              ],
              [
                l10n.exportPdfPeriodBorrowReturnLate,
                '${snap.periodBorrowing} / ${snap.periodReturned} / ${snap.periodLate}',
              ],
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            l10n.exportPdfTopBooksInRange,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (topRows.isEmpty)
            pw.Text(l10n.exportPdfNoTableData)
          else
            pw.TableHelper.fromTextArray(
              headers: [
                l10n.exportColRank,
                l10n.exportColBookTitle,
                l10n.exportColCategory,
                l10n.exportColBorrowCountLong,
              ],
              data: topRows,
            ),
          pw.SizedBox(height: 14),
          pw.Text(
            l10n.exportPdfBorrowRecordsLimited(
              '$pdfBorrowCap',
              '${periodBorrows.length}',
            ),
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (borrowRows.isEmpty)
            pw.Text(l10n.exportPdfNoBorrowRecordsInRange)
          else
            pw.TableHelper.fromTextArray(
              headers: [
                l10n.exportPdfColTicketId,
                l10n.exportPdfColBookId,
                l10n.exportPdfColUserId,
                l10n.exportPdfColStatus,
                l10n.exportPdfColBorrowDate,
                l10n.exportPdfColDueDate,
                'returnDate',
              ],
              data: borrowRows,
            ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Thanh toán phạt (payments)',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (paymentRows.isEmpty)
            pw.Text('—')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['ID', 'userId', 'amount', 'method', 'createdAt'],
              data: paymentRows,
            ),
        ],
      ),
    );

    return List<int>.from(await doc.save());
  }
}
