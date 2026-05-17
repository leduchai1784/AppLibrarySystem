import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../domain/library_report_bundle.dart';

/// Xây workbook Excel đa sheet (Summary / Books / Users / Borrows / Revenue).
///
/// Gói `excel` không hỗ trợ freeze panes — có thể nâng cấp lên Syncfusion sau nếu cần.
class ReportExcelExporter {
  ReportExcelExporter._();

  static int _asInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  static String _ts(dynamic v) {
    if (v is Timestamp) return v.toDate().toLocal().toString().split('.').first;
    return '';
  }

  static String _fmtRange(DateTime start, DateTime end) {
    String f(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${f(start)} — ${f(end)}';
  }

  static Map<String, int> _countByBookId(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> borrows,
  ) {
    final m = <String, int>{};
    for (final d in borrows) {
      final id = '${d.data()['bookId'] ?? ''}'.trim();
      if (id.isEmpty) continue;
      m[id] = (m[id] ?? 0) + 1;
    }
    return m;
  }

  static Map<String, int> _borrowCountByUser(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> borrows,
  ) {
    final m = <String, int>{};
    for (final d in borrows) {
      final id = '${d.data()['userId'] ?? ''}'.trim();
      if (id.isEmpty) continue;
      m[id] = (m[id] ?? 0) + 1;
    }
    return m;
  }

  static Map<String, int> _lateCountByUser(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> borrows,
  ) {
    final m = <String, int>{};
    for (final d in borrows) {
      final uid = '${d.data()['userId'] ?? ''}'.trim();
      if (uid.isEmpty) continue;
      final st = '${d.data()['status'] ?? ''}';
      if (st == 'late') {
        m[uid] = (m[uid] ?? 0) + 1;
      }
    }
    return m;
  }

  static int? _overdueDays(Map<String, dynamic> m) {
    final due = (m['dueDate'] as Timestamp?)?.toDate();
    if (due == null) return null;
    final ret = (m['returnDate'] as Timestamp?)?.toDate();
    final st = '${m['status'] ?? ''}';
    if (st == 'returned' || st == 'late') {
      if (ret == null) return null;
      return ret.difference(due).inDays;
    }
    if (st == 'borrowing') {
      final now = DateTime.now();
      if (now.isAfter(due)) {
        return now.difference(due).inDays;
      }
    }
    return 0;
  }

  static CellStyle _headerStyle() => CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.grey400,
    horizontalAlign: HorizontalAlign.Center,
  );

  static CellStyle _altRowStyle(bool alt) =>
      alt ? CellStyle(backgroundColorHex: ExcelColor.grey100) : CellStyle();

  static void _autoWidth(
    Sheet sheet,
    int maxCol,
    int maxRow, {
    double minW = 10,
    double maxW = 48,
  }) {
    for (var c = 0; c <= maxCol; c++) {
      var len = 8.0;
      for (var r = 0; r <= maxRow; r++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        final t = cell.value?.toString() ?? '';
        if (t.length > len) len = t.length.toDouble();
      }
      final w = (len * 1.1).clamp(minW, maxW);
      sheet.setColumnWidth(c, w);
    }
  }

  /// Trả về bytes `.xlsx`.
  static List<int> build({
    required LibraryReportBundle bundle,
    required AppLocalizations l10n,
  }) {
    final excel = Excel.createExcel();
    final def = excel.getDefaultSheet();
    if (def != null) {
      excel.rename(def, 'Summary');
    }

    _buildSummarySheet(excel['Summary'], bundle, l10n);
    _buildBooksSheet(excel['Books'], bundle);
    _buildUsersSheet(excel['Users'], bundle);
    _buildBorrowsSheet(excel['Borrows'], bundle);
    _buildRevenueSheet(excel['Revenue'], bundle);

    final encoded = excel.encode();
    if (encoded == null) {
      throw StateError(l10n.exportExcelEncodeError);
    }
    return encoded;
  }

  static void _buildSummarySheet(
    Sheet sh,
    LibraryReportBundle bundle,
    AppLocalizations l10n,
  ) {
    final snap = bundle.snapshot;
    var r = 0;
    void cell(int c, int row, dynamic v, {CellStyle? st}) {
      final cl = sh.cell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row),
      );
      if (v is int) {
        cl.value = IntCellValue(v);
      } else if (v is double) {
        cl.value = DoubleCellValue(v);
      } else {
        cl.value = TextCellValue('$v');
      }
      if (st != null) cl.cellStyle = st;
    }

    cell(0, r++, l10n.exportStatReportTitleFull);
    cell(
      0,
      r++,
      l10n.exportStatDateRange(_fmtRange(bundle.rangeStart, bundle.rangeEnd)),
    );
    cell(
      0,
      r++,
      l10n.exportStatExportedAt(
        DateTime.now().toLocal().toString().split('.').first,
      ),
    );
    r++;

    cell(0, r, l10n.exportStatMetric, st: _headerStyle());
    cell(1, r, l10n.exportStatValue, st: _headerStyle());
    r++;
    final rows = <(String, dynamic)>[
      (l10n.exportStatBookTitlesCount, snap.totalBookTitles),
      (l10n.exportStatTotalUsers, snap.totalUsers),
      (l10n.exportStatTotalCopiesQty, snap.totalBookCopies),
      (l10n.exportStatTotalAvailableStock, snap.totalAvailableCopies),
      (l10n.exportStatBorrowsInPeriodBorrowDate, snap.borrowEventsInPeriod),
      (l10n.exportStatActiveTicketsSystemWide, snap.activeBorrowTicketsGlobal),
      (
        l10n.exportStatPeriodBorrowingReturnedLate,
        '${snap.periodBorrowing} / ${snap.periodReturned} / ${snap.periodLate}',
      ),
    ];
    if (snap.onTimeReturnRate != null) {
      rows.add((
        l10n.exportStatOnTimeReturnEstimate,
        '${(snap.onTimeReturnRate! * 100).toStringAsFixed(1)}%',
      ));
    }
    if (snap.avgBorrowDaysReturned != null) {
      rows.add((
        l10n.exportStatAvgBorrowDaysReturned,
        snap.avgBorrowDaysReturned!.toStringAsFixed(1),
      ));
    }
    var alt = false;
    for (final row in rows) {
      cell(0, r, row.$1, st: _altRowStyle(alt));
      cell(1, r, row.$2, st: _altRowStyle(alt));
      r++;
      alt = !alt;
    }
    r++;
    cell(0, r++, l10n.statsMonthlyBorrowsSection, st: _headerStyle());
    cell(0, r, 'Month', st: _headerStyle());
    cell(1, r, l10n.exportStatValue, st: _headerStyle());
    r++;
    alt = false;
    for (final m in snap.borrowsByMonthLast12) {
      cell(0, r, m.$1, st: _altRowStyle(alt));
      cell(1, r, m.$2, st: _altRowStyle(alt));
      r++;
      alt = !alt;
    }
    r++;
    cell(0, r++, l10n.exportStatSectionTopBorrowedPeriod, st: _headerStyle());
    cell(0, r, l10n.exportColRank, st: _headerStyle());
    cell(1, r, l10n.exportColBookTitle, st: _headerStyle());
    cell(2, r, l10n.exportColCategory, st: _headerStyle());
    cell(3, r, l10n.exportColBorrowsShort, st: _headerStyle());
    r++;
    alt = false;
    for (final t in snap.topBorrowed) {
      cell(0, r, t.rank, st: _altRowStyle(alt));
      cell(1, r, t.title, st: _altRowStyle(alt));
      cell(2, r, t.categoryLabel, st: _altRowStyle(alt));
      cell(3, r, t.borrowCount, st: _altRowStyle(alt));
      r++;
      alt = !alt;
    }
    _autoWidth(sh, 3, r - 1);
  }

  static void _buildBooksSheet(Sheet sh, LibraryReportBundle bundle) {
    final borrowByBook = _countByBookId(bundle.borrowRecords);
    const headers = [
      'id',
      'title',
      'isbn',
      'category',
      'author',
      'quantity',
      'available',
      'borrowCount',
      'createdAt',
    ];
    var r = 0;
    for (var c = 0; c < headers.length; c++) {
      sh.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value =
          TextCellValue(headers[c]);
      sh
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
              .cellStyle =
          _headerStyle();
    }
    r++;
    var alt = false;
    for (final d in bundle.books) {
      final m = d.data();
      final id = d.id;
      final st = _altRowStyle(alt);
      void setC(int c, dynamic v) {
        final cl = sh.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        if (v is int) {
          cl.value = IntCellValue(v);
        } else {
          cl.value = TextCellValue('$v');
        }
        cl.cellStyle = st;
      }

      setC(0, id);
      setC(1, '${m['title'] ?? ''}');
      setC(2, '${m['isbn'] ?? ''}');
      setC(3, '${m['category'] ?? m['categoryId'] ?? ''}');
      setC(4, '${m['author'] ?? m['authorName'] ?? ''}');
      setC(5, _asInt(m['quantity'], 0));
      final av = m['availableQuantity'] ?? m['available'] ?? m['quantity'];
      setC(6, _asInt(av, 0));
      setC(7, borrowByBook[id] ?? 0);
      setC(8, _ts(m['createdAt']));
      r++;
      alt = !alt;
    }
    _autoWidth(sh, headers.length - 1, r - 1);
  }

  static void _buildUsersSheet(Sheet sh, LibraryReportBundle bundle) {
    final borrowsByUser = _borrowCountByUser(bundle.borrowRecords);
    final lateByUser = _lateCountByUser(bundle.borrowRecords);
    const headers = [
      'id',
      'email',
      'fullName',
      'role',
      'borrowCount',
      'lateTicketCount',
      'createdAt',
    ];
    var r = 0;
    for (var c = 0; c < headers.length; c++) {
      sh.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value =
          TextCellValue(headers[c]);
      sh
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
              .cellStyle =
          _headerStyle();
    }
    r++;
    var alt = false;
    for (final d in bundle.users) {
      final m = d.data();
      final id = d.id;
      final st = _altRowStyle(alt);
      void setC(int c, dynamic v) {
        final cl = sh.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        if (v is int) {
          cl.value = IntCellValue(v);
        } else {
          cl.value = TextCellValue('$v');
        }
        cl.cellStyle = st;
      }

      setC(0, id);
      setC(1, '${m['email'] ?? ''}');
      setC(2, '${m['fullName'] ?? ''}');
      setC(3, '${m['role'] ?? ''}');
      setC(4, borrowsByUser[id] ?? 0);
      setC(5, lateByUser[id] ?? 0);
      setC(6, _ts(m['createdAt']));
      r++;
      alt = !alt;
    }
    _autoWidth(sh, headers.length - 1, r - 1);
  }

  static void _buildBorrowsSheet(Sheet sh, LibraryReportBundle bundle) {
    final all = bundle.borrowRecords;
    const headers = [
      'id',
      'bookId',
      'userId',
      'status',
      'borrowDate',
      'dueDate',
      'returnDate',
      'overdueDays',
      'bookTitleSnapshot',
      'fineAmount',
      'finePaid',
    ];
    var r = 0;
    for (var c = 0; c < headers.length; c++) {
      sh.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value =
          TextCellValue(headers[c]);
      sh
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
              .cellStyle =
          _headerStyle();
    }
    r++;
    var alt = false;
    for (final d in all) {
      final m = d.data();
      final st = _altRowStyle(alt);
      void setC(int c, dynamic v) {
        final cl = sh.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        if (v is int) {
          cl.value = IntCellValue(v);
        } else {
          cl.value = TextCellValue('$v');
        }
        cl.cellStyle = st;
      }

      setC(0, d.id);
      setC(1, '${m['bookId'] ?? ''}');
      setC(2, '${m['userId'] ?? ''}');
      setC(3, '${m['status'] ?? ''}');
      setC(4, _ts(m['borrowDate']));
      setC(5, _ts(m['dueDate']));
      setC(6, _ts(m['returnDate']));
      setC(7, _overdueDays(m) ?? '');
      setC(8, '${m['bookTitleSnapshot'] ?? ''}');
      setC(9, _asInt(m['fineAmount'], 0));
      setC(10, '${m['finePaid'] ?? false}');
      r++;
      alt = !alt;
    }
    _autoWidth(sh, headers.length - 1, r - 1);
  }

  static void _buildRevenueSheet(Sheet sh, LibraryReportBundle bundle) {
    const headers = [
      'id',
      'userId',
      'borrowRecordId',
      'amount',
      'method',
      'processedBy',
      'createdAt',
    ];
    var r = 0;
    for (var c = 0; c < headers.length; c++) {
      sh.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value =
          TextCellValue(headers[c]);
      sh
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
              .cellStyle =
          _headerStyle();
    }
    r++;
    var alt = false;
    for (final d in bundle.payments) {
      final m = d.data();
      final st = _altRowStyle(alt);
      void setC(int c, dynamic v) {
        final cl = sh.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        if (v is int) {
          cl.value = IntCellValue(v);
        } else {
          cl.value = TextCellValue('$v');
        }
        cl.cellStyle = st;
      }

      setC(0, d.id);
      setC(1, '${m['userId'] ?? ''}');
      setC(2, '${m['borrowRecordId'] ?? ''}');
      setC(3, _asInt(m['amount'], 0));
      setC(4, '${m['method'] ?? ''}');
      setC(5, '${m['processedBy'] ?? ''}');
      setC(6, _ts(m['createdAt']));
      r++;
      alt = !alt;
    }
    if (bundle.payments.isEmpty) {
      sh.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r)).value =
          TextCellValue('—');
    }
    _autoWidth(sh, headers.length - 1, r > 0 ? r - 1 : 1);
  }
}
