import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../core/constants/app_constants.dart';
import '../gen/l10n/app_localizations.dart';
import 'category_ensure_service.dart';
import 'genre_author_resolve_service.dart';

/// Đọc file Excel (.xlsx) và ghi hàng loạt sách lên Firestore `books`.
///
/// Dòng đầu: tiêu đề cột. Hỗ trợ tên cột (không phân biệt hoa thường):
/// - title / tên sách / tieu_de / name
/// - author / tác giả / tac_gia
/// - category / danh mục / danh_muc (nhóm demo — khác **thể loại**)
/// - genre / thể loại / the_loai → liên kết `genres` (tạo nếu chưa có) → `genreId`
/// - genre_id / genreid / mã thể loại → gán trực tiếp `genreId` (document id có sẵn)
/// - published_year / năm xuất bản / nam_xuat_ban → `publishedYear`
/// - isbn / mã isbn
/// - quantity / số lượng / so_luong / qty
/// - description / mô tả / mo_ta / desc
///
/// Đọc file: ưu tiên [SpreadsheetDecoder] (ít lỗi với file Excel/Google Sheets),
/// nếu lỗi mới dùng package `excel` làm dự phòng.
class BookExcelImportService {
  BookExcelImportService._();

  static final Map<String, String> _headerToField = {
    'title': 'title',
    'tên sách': 'title',
    'ten sach': 'title',
    'tieu de': 'title',
    'tựa đề': 'title',
    'tua de': 'title',
    'name': 'title',
    'author': 'author',
    'tác giả': 'author',
    'tac gia': 'author',
    'category': 'category',
    'danh mục': 'category',
    'danh muc': 'category',
    'genre': 'genreName',
    'thể loại': 'genreName',
    'the loai': 'genreName',
    'ten the loai': 'genreName',
    'tên thể loại': 'genreName',
    'the loai sach': 'genreName',
    'genre name': 'genreName',
    'genre_id': 'genreIdRaw',
    'genreid': 'genreIdRaw',
    'mã thể loại': 'genreIdRaw',
    'ma the loai': 'genreIdRaw',
    'id thể loại': 'genreIdRaw',
    'publishedyear': 'publishedYear',
    'published year': 'publishedYear',
    'năm xuất bản': 'publishedYear',
    'nam xuat ban': 'publishedYear',
    'nam xuatban': 'publishedYear',
    'năm xb': 'publishedYear',
    'nam xb': 'publishedYear',
    'year published': 'publishedYear',
    'xuất bản': 'publishedYear',
    'xuat ban': 'publishedYear',
    'isbn': 'isbn',
    'mã isbn': 'isbn',
    'ma isbn': 'isbn',
    'quantity': 'quantity',
    'số lượng': 'quantity',
    'so luong': 'quantity',
    'qty': 'quantity',
    'sl': 'quantity',
    'description': 'description',
    'mô tả': 'description',
    'mo ta': 'description',
    'desc': 'description',
  };

  static String _normHeader(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll('_', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  static String _plainFromTextSpan(TextSpan span) {
    final buf = StringBuffer();
    void walk(TextSpan s) {
      if (s.text != null) buf.write(s.text);
      final ch = s.children;
      if (ch != null) {
        for (final c in ch) {
          walk(c);
        }
      }
    }

    walk(span);
    return buf.toString().trim();
  }

  static String _cellToString(Data? cell) {
    final v = cell?.value;
    if (v == null) return '';
    return switch (v) {
      TextCellValue(:final value) => _plainFromTextSpan(value),
      IntCellValue(:final value) => value.toString(),
      DoubleCellValue(:final value) =>
        (value == value.roundToDouble()) ? value.round().toString() : value.toString(),
      FormulaCellValue(:final formula) => formula,
      DateCellValue(:final year, :final month, :final day) =>
        '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year',
      DateTimeCellValue() => '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}',
      TimeCellValue() => v.toString(),
      BoolCellValue(:final value) => value.toString(),
    };
  }

  static String _dynamicToString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v.trim();
    if (v is int) return v.toString();
    if (v is double) {
      if (v.isFinite && v == v.roundToDouble()) return v.round().toString();
      return v.toString();
    }
    if (v is DateTime) {
      return '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}';
    }
    if (v is bool) return v.toString();
    return v.toString().trim();
  }

  static void _padGrid(List<List<String>> grid) {
    if (grid.isEmpty) return;
    final m = grid.fold<int>(0, (a, r) => r.length > a ? r.length : a);
    for (final r in grid) {
      while (r.length < m) {
        r.add('');
      }
    }
  }

  static List<List<String>> _stringGridFromSpreadsheetRows(List<List> rows) {
    final out = <List<String>>[];
    for (final r in rows) {
      out.add([
        for (var i = 0; i < r.length; i++) _dynamicToString(r[i]),
      ]);
    }
    _padGrid(out);
    return out;
  }

  static List<List<String>> _gridFromExcelSheet(Sheet sheet) {
    final out = <List<String>>[];
    for (final row in sheet.rows) {
      out.add([
        for (var i = 0; i < row.length; i++) _cellToString(i < row.length ? row[i] : null),
      ]);
    }
    _padGrid(out);
    return out;
  }

  static SpreadsheetTable? _firstTableWithRows(SpreadsheetDecoder dec) {
    if (dec.tables.isEmpty) return null;
    for (final t in dec.tables.values) {
      if (t.rows.isNotEmpty) return t;
    }
    return null;
  }

  /// Trả về danh sách map dữ liệu Firestore (chưa ghi) và lỗi theo dòng.
  static ({List<Map<String, dynamic>> books, List<String> parseErrors}) parseXlsx(
    Uint8List bytes,
    AppLocalizations t,
  ) {
    Object? primaryError;
    try {
      final dec = SpreadsheetDecoder.decodeBytes(bytes);
      final table = _firstTableWithRows(dec);
      if (table == null) {
        return (
          books: <Map<String, dynamic>>[],
          parseErrors: <String>[t.excelErrNoSheetRows],
        );
      }
      final grid = _stringGridFromSpreadsheetRows(table.rows);
      return _parseStringGrid(grid, t);
    } catch (e) {
      primaryError = e;
    }

    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        return _parseFailed(primaryError, t);
      }
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];
      if (sheet == null || sheet.rows.isEmpty) {
        return (
          books: <Map<String, dynamic>>[],
          parseErrors: <String>[t.excelErrSheetEmpty],
        );
      }
      final grid = _gridFromExcelSheet(sheet);
      return _parseStringGrid(grid, t);
    } catch (e2) {
      return (
        books: <Map<String, dynamic>>[],
        parseErrors: <String>[
          t.excelErrReadFailed('$primaryError', '$e2'),
        ],
      );
    }
  }

  static ({List<Map<String, dynamic>> books, List<String> parseErrors}) _parseFailed(
    Object? primaryError,
    AppLocalizations t,
  ) {
    return (
      books: <Map<String, dynamic>>[],
      parseErrors: <String>[
        t.excelErrReadFailedShort('$primaryError'),
      ],
    );
  }

  static ({List<Map<String, dynamic>> books, List<String> parseErrors}) _parseStringGrid(
    List<List<String>> grid,
    AppLocalizations t,
  ) {
    final errors = <String>[];
    final books = <Map<String, dynamic>>[];

    if (grid.isEmpty) {
      return (books: books, parseErrors: <String>[t.excelErrSheetEmpty]);
    }

    final headerRow = grid.first;
    final colField = <int, String>{};

    for (var c = 0; c < headerRow.length; c++) {
      final h = _normHeader(headerRow[c]);
      if (h.isEmpty) continue;
      final field = _headerToField[h];
      if (field != null) {
        colField[c] = field;
      }
    }

    if (!colField.values.contains('title') || !colField.values.contains('author')) {
      return (
        books: books,
        parseErrors: <String>[t.excelErrHeaderRow],
      );
    }

    for (var r = 1; r < grid.length; r++) {
      final row = grid[r];

      String? title;
      String? author;
      var category = kDefaultBookCategory;
      var isbn = '';
      var quantity = 1;
      var description = '';
      String? genreNameCell;
      String? genreIdRawCell;
      int? publishedYear;

      for (final e in colField.entries) {
        final col = e.key;
        final field = e.value;
        final text = col < row.length ? row[col] : '';
        switch (field) {
          case 'title':
            title = text;
            break;
          case 'author':
            author = text;
            break;
          case 'category':
            if (text.isNotEmpty) category = text;
            break;
          case 'genreName':
            final t = text.trim();
            if (t.isNotEmpty) genreNameCell = t;
            break;
          case 'genreIdRaw':
            final t = text.trim();
            if (t.isNotEmpty) genreIdRawCell = t;
            break;
          case 'publishedYear':
            if (text.isNotEmpty) {
              final n = num.tryParse(text.replaceAll(RegExp(r'[^\d.]'), ''));
              if (n != null) publishedYear = n.round();
            }
            break;
          case 'isbn':
            isbn = text;
            break;
          case 'quantity':
            if (text.isNotEmpty) {
              final n = num.tryParse(text.replaceAll(',', '.'));
              if (n != null && n >= 1) quantity = n.round();
            }
            break;
          case 'description':
            description = text;
            break;
        }
      }

      final ti = title?.trim() ?? '';
      final au = author?.trim() ?? '';
      if (ti.isEmpty && au.isEmpty) continue;

      if (ti.isEmpty) {
        errors.add(t.excelErrRowMissingTitle(r + 1));
        continue;
      }
      if (au.isEmpty) {
        errors.add(t.excelErrRowMissingAuthor(r + 1));
        continue;
      }

      if (quantity < 1) {
        errors.add(t.excelErrRowInvalidQuantity(r + 1));
        continue;
      }

      final rowMap = <String, dynamic>{
        'title': ti,
        'author': au,
        'category': category,
        'categoryId': category,
        'isbn': isbn,
        'description': description,
        'quantity': quantity,
        'isAvailable': true,
        'availableQuantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalBorrowCount': 0,
        'imageUrl': '',
      };
      if (publishedYear != null) rowMap['publishedYear'] = publishedYear;
      if (genreNameCell != null) rowMap['_importGenreName'] = genreNameCell;
      if (genreIdRawCell != null) rowMap['_importGenreId'] = genreIdRawCell;
      books.add(rowMap);
    }

    if (books.isEmpty && errors.isEmpty) {
      errors.add(t.excelErrNoValidRows);
    }

    return (books: books, parseErrors: errors);
  }

  /// Ghi [books] (đã parse) vào Firestore; chia batch tối đa 450.
  static Future<({int written, String? error})> commit(
    List<Map<String, dynamic>> books,
    AppLocalizations t,
  ) async {
    if (books.isEmpty) return (written: 0, error: null);

    try {
      await CategoryEnsureService.ensureForBookMaps(books);
      await GenreAuthorResolveService.applyExcelLinks(books);
    } catch (e) {
      return (written: 0, error: t.excelErrEnsureCategory('$e'));
    }

    final ref = FirebaseFirestore.instance.collection('books');
    const chunk = 450;
    var written = 0;

    try {
      for (var i = 0; i < books.length; i += chunk) {
        final end = (i + chunk > books.length) ? books.length : i + chunk;
        final batch = FirebaseFirestore.instance.batch();
        for (var j = i; j < end; j++) {
          final doc = ref.doc();
          batch.set(doc, books[j]);
        }
        await batch.commit();
        written += end - i;
      }
      return (written: written, error: null);
    } catch (e) {
      return (written: written, error: e.toString());
    }
  }
}
