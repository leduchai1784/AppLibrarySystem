import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../features/statistics/library_statistics_engine.dart';
import '../gen/l10n/app_localizations.dart';

/// Xuất snapshot JSON / Excel / PDF (sách + phiếu mượn theo khoảng ngày) cho nhân sự.
class LibraryDataExportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  /// Nạp sách + toàn bộ phiếu (giới hạn) + users + categories — cùng logic [computeLibraryStatistics].
  static Future<_StatisticsBundle> _loadStatisticsBundle({
    required DateTime start,
    required DateTime end,
  }) async {
    final booksSnap = await _db.collection('books').get();
    final usersSnap = await _db.collection('users').get();
    final catSnap = await _db.collection('categories').get();
    final allBorrowsSnap = await _db.collection('borrow_records').limit(15000).get();
    final cfgSnap = await _db.collection('library_settings').doc('config').get();
    return _StatisticsBundle(
      books: booksSnap.docs,
      allBorrows: allBorrowsSnap.docs,
      users: usersSnap.docs,
      categories: catSnap.docs,
      libraryConfig: cfgSnap.data(),
      rangeStart: start,
      rangeEnd: end,
    );
  }

  static int _parseInt(dynamic v, int fallback) {
    if (v is int) return v;
    return int.tryParse('$v') ?? fallback;
  }

  static bool _borrowDocInRange(
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

  static String _excelCellStr(dynamic v) {
    if (v == null) return '';
    if (v is Timestamp) {
      return v.toDate().toLocal().toString().split('.').first;
    }
    return v.toString();
  }

  static Future<String> buildLibraryJsonExport() async {
    final booksSnap = await _db.collection('books').get();
    final categoriesSnap = await _db.collection('categories').get();
    final borrowsSnap = await _db.collection('borrow_records').limit(5000).get();

    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'version': 1,
      'books': booksSnap.docs.map((d) => _docJson(d.id, d.data())).toList(),
      'categories': categoriesSnap.docs.map((d) => _docJson(d.id, d.data())).toList(),
      'borrow_records': borrowsSnap.docs.map((d) => _docJson(d.id, d.data())).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Báo cáo Excel (.xlsx) — tổng quan khớp màn thống kê + sách + phiếu trong kỳ + top người dùng/tác giả.
  static Future<List<int>> buildStatisticsExcelBytes({
    required DateTime start,
    required DateTime end,
    required AppLocalizations l10n,
  }) async {
    final bundle = await _loadStatisticsBundle(start: start, end: end);
    final snap = computeLibraryStatistics(
      bookDocs: bundle.books,
      borrowDocsAll: bundle.allBorrows,
      userDocs: bundle.users,
      categoryDocs: bundle.categories,
      periodStart: bundle.rangeStart,
      periodEnd: bundle.rangeEnd,
    );
    final periodBorrows =
        bundle.allBorrows.where((d) => _borrowDocInRange(d, bundle.rangeStart, bundle.rangeEnd)).toList();

    final excel = Excel.createExcel();
    final defaultName = excel.getDefaultSheet();
    if (defaultName != null) {
      excel.rename(defaultName, 'Tong_quan');
    }
    final sumSheet = excel['Tong_quan'];
    var row = 0;
    void setCell(int c, int r, dynamic v) {
      final cell = sumSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
      if (v is int) {
        cell.value = IntCellValue(v);
      } else {
        cell.value = TextCellValue(v.toString());
      }
    }

    setCell(0, row++, l10n.exportStatReportTitleFull);
    setCell(0, row++, l10n.exportStatDateRange(_fmtRange(bundle.rangeStart, bundle.rangeEnd)));
    row++;
    setCell(0, row, l10n.exportStatMetric);
    setCell(1, row, l10n.exportStatValue);
    row++;
    setCell(0, row, l10n.exportStatBookTitlesCount);
    setCell(1, row, snap.totalBookTitles);
    row++;
    setCell(0, row, l10n.exportStatTotalUsers);
    setCell(1, row, snap.totalUsers);
    row++;
    setCell(0, row, l10n.exportStatTotalCopiesQty);
    setCell(1, row, snap.totalBookCopies);
    row++;
    setCell(0, row, l10n.exportStatTotalAvailableStock);
    setCell(1, row, snap.totalAvailableCopies);
    row++;
    setCell(0, row, l10n.exportStatBorrowsInPeriodBorrowDate);
    setCell(1, row, snap.borrowEventsInPeriod);
    row++;
    setCell(0, row, l10n.exportStatActiveTicketsSystemWide);
    setCell(1, row, snap.activeBorrowTicketsGlobal);
    row++;
    setCell(0, row, l10n.exportStatPeriodBorrowingReturnedLate);
    setCell(1, row, '${snap.periodBorrowing} / ${snap.periodReturned} / ${snap.periodLate}');
    row++;
    if (snap.onTimeReturnRate != null) {
      setCell(0, row, l10n.exportStatOnTimeReturnEstimate);
      setCell(1, row, '${(snap.onTimeReturnRate! * 100).toStringAsFixed(1)}%');
      row++;
    }
    if (snap.avgBorrowDaysReturned != null) {
      setCell(0, row, l10n.exportStatAvgBorrowDaysReturned);
      setCell(1, row, snap.avgBorrowDaysReturned!.toStringAsFixed(1));
      row++;
    }
    row += 1;

    setCell(0, row++, l10n.exportStatSectionTopBorrowedPeriod);
    setCell(0, row, l10n.exportColRank);
    setCell(1, row, l10n.exportColBookTitle);
    setCell(2, row, l10n.exportColCategory);
    setCell(3, row, l10n.exportColBorrowsShort);
    row++;
    for (final tr in snap.topBorrowed) {
      setCell(0, row, tr.rank);
      setCell(1, row, tr.title);
      setCell(2, row, tr.categoryLabel);
      setCell(3, row, tr.borrowCount);
      row++;
    }

    final booksSheet = excel['Sach'];
    final bookHeaders = [
      l10n.exportExcelColId,
      l10n.exportExcelColTitle,
      l10n.exportExcelColAuthor,
      l10n.exportExcelColCategoryField,
      l10n.exportExcelColQuantity,
      l10n.exportExcelColAvailableQuantity,
    ];
    for (var c = 0; c < bookHeaders.length; c++) {
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(bookHeaders[c]);
    }
    var br = 1;
    for (final d in bundle.books) {
      final m = d.data();
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: br)).value = TextCellValue(d.id);
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: br)).value =
          TextCellValue('${m['title'] ?? ''}');
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: br)).value =
          TextCellValue('${m['author'] ?? m['authorName'] ?? ''}');
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: br)).value =
          TextCellValue('${m['category'] ?? m['categoryId'] ?? ''}');
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: br)).value =
          IntCellValue(_parseInt(m['quantity'], 0));
      final av = m['availableQuantity'] ?? m['available'] ?? m['quantity'];
      booksSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: br)).value =
          IntCellValue(_parseInt(av, 0));
      br++;
    }

    final borrowSheet = excel['PhieuMuon'];
    final bh = [
      l10n.exportExcelColBorrowId,
      l10n.exportExcelColBookId,
      l10n.exportExcelColUserId,
      l10n.exportExcelColStatus,
      l10n.exportExcelColBorrowDate,
      l10n.exportExcelColDueDate,
      l10n.exportExcelColReturnDate,
      l10n.exportExcelColBookTitleSnapshot,
    ];
    for (var c = 0; c < bh.length; c++) {
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(bh[c]);
    }
    final ndSheet = excel['NguoiDung_Top'];
    ndSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue(l10n.exportExcelColUserId);
    ndSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue(l10n.exportExcelColDisplayName);
    ndSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue(l10n.exportExcelColBorrowsInPeriod);
    var nr = 1;
    for (final e in snap.topUserBorrowers) {
      ndSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: nr)).value = TextCellValue(e.$1);
      ndSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: nr)).value = TextCellValue(e.$2);
      ndSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: nr)).value = IntCellValue(e.$3);
      nr++;
    }

    final tgSheet = excel['TacGia'];
    tgSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue(l10n.exportExcelColAuthorName);
    tgSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue(l10n.exportExcelColAuthorBorrowsInPeriod);
    var tr = 1;
    for (final a in snap.authorBorrowCounts) {
      tgSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: tr)).value = TextCellValue(a.$1);
      tgSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: tr)).value = IntCellValue(a.$2);
      tr++;
    }

    var bor = 1;
    for (final d in periodBorrows) {
      final m = d.data();
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: bor)).value = TextCellValue(d.id);
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: bor)).value =
          TextCellValue(_excelCellStr(m['bookId']));
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: bor)).value =
          TextCellValue(_excelCellStr(m['userId']));
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: bor)).value =
          TextCellValue(_excelCellStr(m['status']));
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: bor)).value =
          TextCellValue(_excelCellStr(m['borrowDate']));
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: bor)).value =
          TextCellValue(_excelCellStr(m['dueDate']));
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: bor)).value =
          TextCellValue(_excelCellStr(m['returnDate']));
      borrowSheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: bor)).value =
          TextCellValue('${m['bookTitleSnapshot'] ?? ''}');
      bor++;
    }

    final encoded = excel.encode();
    if (encoded == null) {
      throw StateError(l10n.exportExcelEncodeError);
    }
    return encoded;
  }

  static String _fmtRange(DateTime start, DateTime end) {
    String f(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${f(start)} — ${f(end)}';
  }

  static String _fmtTs(dynamic v) {
    if (v is Timestamp) {
      return v.toDate().toLocal().toString().split('.').first;
    }
    return '';
  }

  /// Báo cáo PDF (UTF-8, font Noto Sans — tải qua [PdfGoogleFonts], cần mạng lần đầu).
  static Future<List<int>> buildStatisticsPdfBytes({
    required DateTime start,
    required DateTime end,
    required AppLocalizations l10n,
  }) async {
    final bundle = await _loadStatisticsBundle(start: start, end: end);
    final snap = computeLibraryStatistics(
      bookDocs: bundle.books,
      borrowDocsAll: bundle.allBorrows,
      userDocs: bundle.users,
      categoryDocs: bundle.categories,
      periodStart: bundle.rangeStart,
      periodEnd: bundle.rangeEnd,
    );
    final periodBorrows =
        bundle.allBorrows.where((d) => _borrowDocInRange(d, bundle.rangeStart, bundle.rangeEnd)).toList();
    final topRows =
        snap.topBorrowed.map((e) => ['${e.rank}', e.title, e.categoryLabel, '${e.borrowCount}']).toList();
    final exportedAtLocal = DateTime.now().toLocal().toString().split('.').first;

    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final borrowTable = <List<String>>[];
    const pdfBorrowCap = 400;
    for (var i = 0; i < periodBorrows.length && i < pdfBorrowCap; i++) {
      final d = periodBorrows[i];
      final m = d.data();
      borrowTable.add([
        d.id,
        '${m['bookId'] ?? ''}',
        '${m['userId'] ?? ''}',
        '${m['status'] ?? ''}',
        _fmtTs(m['borrowDate']),
        _fmtTs(m['dueDate']),
      ]);
    }

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) {
          return [
            pw.Text(
              l10n.exportStatReportTitlePdf,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(l10n.exportStatDateRange(_fmtRange(bundle.rangeStart, bundle.rangeEnd))),
            pw.Text(l10n.exportStatExportedAt(exportedAtLocal)),
            pw.SizedBox(height: 16),
            pw.Text(l10n.statsOverviewSection, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [l10n.exportStatMetric, l10n.exportStatValue],
              data: <List<String>>[
                [l10n.exportStatBookTitlesCount, '${snap.totalBookTitles}'],
                [l10n.exportStatTotalUsers, '${snap.totalUsers}'],
                [l10n.exportStatTotalCopiesQty, '${snap.totalBookCopies}'],
                [l10n.statsAvailableTitle, '${snap.totalAvailableCopies}'],
                [l10n.statsCardBorrowTurnsPeriod, '${snap.borrowEventsInPeriod}'],
                [l10n.exportStatActiveTicketsSystemWide, '${snap.activeBorrowTicketsGlobal}'],
                [l10n.exportPdfPeriodBorrowReturnLate, '${snap.periodBorrowing} / ${snap.periodReturned} / ${snap.periodLate}'],
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Text(l10n.exportPdfTopBooksInRange, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
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
            pw.SizedBox(height: 16),
            pw.Text(
              l10n.exportPdfBorrowRecordsLimited('$pdfBorrowCap', '${periodBorrows.length}'),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (borrowTable.isEmpty)
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
                ],
                data: borrowTable,
              ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Xuất phiếu mượn của một sinh viên (JSON nhỏ, phù hợp chia sẻ trên mobile).
  static Future<String> buildStudentBorrowsJsonExport(String userId) async {
    final borrowsSnap = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .limit(500)
        .get();

    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'version': 1,
      'userId': userId,
      'borrow_records': borrowsSnap.docs.map((d) => _docJson(d.id, d.data())).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class _StatisticsBundle {
  const _StatisticsBundle({
    required this.books,
    required this.allBorrows,
    required this.users,
    required this.categories,
    required this.libraryConfig,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> books;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> allBorrows;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> users;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> categories;
  final Map<String, dynamic>? libraryConfig;
  final DateTime rangeStart;
  final DateTime rangeEnd;
}
