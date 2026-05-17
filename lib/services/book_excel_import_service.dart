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
/// - image_url / image url / ảnh bìa / cover url → URL ảnh bìa (`https://…`), không nhúng file ảnh trong .xlsx.
///
/// Đọc file: ưu tiên [SpreadsheetDecoder] (ít lỗi với file Excel/Google Sheets),
/// nếu lỗi mới dùng package `excel` làm dự phòng.
class BookExcelImportService {
  BookExcelImportService._();

  /// Trích URL http(s) đầu tiên trong chuỗi ô Excel.
  ///
  /// Hỗ trợ các trường hợp phổ biến:
  /// - Người dùng ép text bằng dấu nháy đơn: `'https://...`
  /// - Cell có công thức: `=HYPERLINK("https://...","...")`
  /// - Có ký tự thừa trước/sau URL.
  static String? _extractFirstHttpUrl(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    // Excel text prefix.
    if (s.startsWith("'")) s = s.substring(1).trim();
    // Nếu là công thức HYPERLINK, lấy URL trong dấu nháy.
    final mHyper = RegExp(
      r'HYPERLINK\(\"(https?://[^\"]+)\"',
      caseSensitive: false,
    ).firstMatch(s);
    if (mHyper != null) return mHyper.group(1)?.trim();
    // Bắt URL đầu tiên.
    final m = RegExp(r'(https?://\S+)', caseSensitive: false).firstMatch(s);
    if (m == null) return null;
    var url = (m.group(1) ?? '').trim();
    // Cắt dấu đóng/quote hay dấu phẩy cuối.
    url = url.replaceAll(RegExp(r'[\"\\),;]+$'), '');
    return url.isEmpty ? null : url;
  }

  /// Lấy URL ảnh đầu tiên hợp lệ trong nhóm dòng cùng ISBN.
  static String? _firstHttpImageUrlFromRows(List<Map<String, dynamic>> rows) {
    for (final r in rows) {
      final u = (r['imageUrl'] ?? '').toString().trim();
      final extracted = _extractFirstHttpUrl(u);
      if (extracted != null) return extracted;
    }
    return null;
  }

  /// Chuẩn hoá ISBN để làm khoá gộp và tạo docId ổn định.
  /// - Bỏ khoảng trắng, dấu gạch, ký tự lạ; giữ [0-9] và 'X' (ISBN-10 checksum).
  /// - Trả về chuỗi UPPERCASE; rỗng nghĩa là coi như không có ISBN.
  static String normalizeIsbn(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) return '';
    final kept = s.replaceAll(RegExp(r'[^0-9X]'), '');
    return kept.trim();
  }

  /// Doc id cố định theo ISBN để tránh tạo trùng bản ghi.
  /// Dùng prefix để dễ phân biệt với docId ngẫu nhiên cũ.
  static String _bookDocIdFromIsbn(String normalizedIsbn) =>
      'isbn_$normalizedIsbn';

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
    'image_url': 'imageUrl',
    'imageurl': 'imageUrl',
    'image url': 'imageUrl',
    'cover image url': 'imageUrl',
    'url ảnh': 'imageUrl',
    'url anh': 'imageUrl',
    'url ảnh bìa': 'imageUrl',
    'url anh bia': 'imageUrl',
    'ảnh bìa': 'imageUrl',
    'ảnh bìa url': 'imageUrl',
    'anh bia': 'imageUrl',
    'anh bia url': 'imageUrl',
    'cover': 'imageUrl',
    'cover_url': 'imageUrl',
    'cover url': 'imageUrl',
    'coverurl': 'imageUrl',
    'hình ảnh': 'imageUrl',
    'hinh anh': 'imageUrl',
    'link ảnh': 'imageUrl',
    'link anh': 'imageUrl',
    'photo url': 'imageUrl',
    'picture url': 'imageUrl',
    'thumbnail_url': 'imageUrl',
    'thumbnail url': 'imageUrl',
  };

  static String _normHeader(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll('_', ' ');
    // Bỏ ký tự đặc biệt để header kiểu "Ảnh bìa (URL)" vẫn map được.
    s = s.replaceAll(
      RegExp(
        r'[()\[\]{}<>.,:;!?/\\|`"'
        '“”‘’]',
      ),
      ' ',
    );
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
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
        (value == value.roundToDouble())
            ? value.round().toString()
            : value.toString(),
      FormulaCellValue(:final formula) => formula,
      DateCellValue(:final year, :final month, :final day) =>
        '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year',
      DateTimeCellValue() =>
        '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year}',
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
      out.add([for (var i = 0; i < r.length; i++) _dynamicToString(r[i])]);
    }
    _padGrid(out);
    return out;
  }

  static List<List<String>> _gridFromExcelSheet(Sheet sheet) {
    final out = <List<String>>[];
    for (final row in sheet.rows) {
      out.add([
        for (var i = 0; i < row.length; i++)
          _cellToString(i < row.length ? row[i] : null),
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
  static ({List<Map<String, dynamic>> books, List<String> parseErrors})
  parseXlsx(Uint8List bytes, AppLocalizations t) {
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
        parseErrors: <String>[t.excelErrReadFailed('$primaryError', '$e2')],
      );
    }
  }

  static ({List<Map<String, dynamic>> books, List<String> parseErrors})
  _parseFailed(Object? primaryError, AppLocalizations t) {
    return (
      books: <Map<String, dynamic>>[],
      parseErrors: <String>[t.excelErrReadFailedShort('$primaryError')],
    );
  }

  static ({List<Map<String, dynamic>> books, List<String> parseErrors})
  _parseStringGrid(List<List<String>> grid, AppLocalizations t) {
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

    if (!colField.values.contains('title') ||
        !colField.values.contains('author')) {
      return (books: books, parseErrors: <String>[t.excelErrHeaderRow]);
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
      var imageUrlCell = '';

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
          case 'imageUrl':
            imageUrlCell = text.trim();
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
      };
      final extractedUrl = _extractFirstHttpUrl(imageUrlCell);
      if (extractedUrl != null) {
        rowMap['imageUrl'] = extractedUrl;
      } else {
        rowMap['imageUrl'] = '';
      }
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

    // Web: một số nguồn dữ liệu có thể trả Map bất biến → clone để đảm bảo luôn mutable
    // (GenreAuthorResolveService dùng remove()/gán field).
    final working = books.map((b) => Map<String, dynamic>.from(b)).toList();

    try {
      await CategoryEnsureService.ensureForBookMaps(working);
      await GenreAuthorResolveService.applyExcelLinks(working);
    } catch (e) {
      return (written: 0, error: t.excelErrEnsureCategory('$e'));
    }

    final col = FirebaseFirestore.instance.collection('books');

    // 1) Gom theo ISBN (để gộp tồn kho nếu đã có) và tách nhóm không ISBN.
    final noIsbnRows = <Map<String, dynamic>>[];
    final isbnToRows = <String, List<Map<String, dynamic>>>{};
    for (final b in working) {
      final raw = (b['isbn'] ?? '').toString();
      final norm = normalizeIsbn(raw);
      if (norm.isEmpty) {
        noIsbnRows.add(b);
        continue;
      }
      (isbnToRows[norm] ??= <Map<String, dynamic>>[]).add(b);
    }

    // Số dòng hợp lệ đã xử lý (không phải số ISBN duy nhất).
    var written = 0;

    // 2) So sánh ISBN với dữ liệu đã có:
    // - Ưu tiên docId mới `isbn_<norm>` nếu đã tồn tại.
    // - Nếu chưa có docId đó, tìm theo field `isbn == <norm>` (dữ liệu cũ auto-id).
    // - Nếu có rồi: chỉ INCREMENT quantity/availableQuantity, không tạo sách mới.
    final isbnKeys = isbnToRows.keys.toList()..sort();

    // 2.1) Prefetch: map ISBN -> docRef hiện có (theo field isbn) để gộp vào data cũ.
    final isbnToExistingDocRef =
        <String, DocumentReference<Map<String, dynamic>>>{};
    const whereInChunk = 30; // giới hạn whereIn
    try {
      for (var i = 0; i < isbnKeys.length; i += whereInChunk) {
        final end = (i + whereInChunk > isbnKeys.length)
            ? isbnKeys.length
            : i + whereInChunk;
        final part = isbnKeys.sublist(i, end);
        final snap = await col.where('isbn', whereIn: part).get();
        for (final d in snap.docs) {
          final v = (d.data()['isbn'] ?? '').toString();
          final norm = normalizeIsbn(v);
          if (norm.isEmpty) continue;
          // lấy doc đầu tiên (limit 1 theo isbn); nếu DB đang trùng isbn, đây là lý do nên migrate dọn dẹp.
          isbnToExistingDocRef.putIfAbsent(norm, () => d.reference);
        }
      }
    } catch (e) {
      return (written: 0, error: e.toString());
    }

    // 2.2) Prefetch tồn tại của docId mới `isbn_<norm>` (để ưu tiên doc chuẩn hoá nếu đã có).
    final isbnIdExists = <String, bool>{};
    const idChunk = 80;
    try {
      for (var i = 0; i < isbnKeys.length; i += idChunk) {
        final end = (i + idChunk > isbnKeys.length)
            ? isbnKeys.length
            : i + idChunk;
        final part = isbnKeys.sublist(i, end);
        final snaps = await Future.wait(
          part.map((norm) => col.doc(_bookDocIdFromIsbn(norm)).get()),
        );
        for (var j = 0; j < part.length; j++) {
          isbnIdExists[part[j]] = snaps[j].exists;
        }
      }
    } catch (e) {
      return (written: 0, error: e.toString());
    }

    // 2.3) Ghi: batch write theo chunk để tránh vượt giới hạn 500 ops.
    const writeChunk = 350;
    try {
      for (var i = 0; i < isbnKeys.length; i += writeChunk) {
        final end = (i + writeChunk > isbnKeys.length)
            ? isbnKeys.length
            : i + writeChunk;
        final part = isbnKeys.sublist(i, end);
        final batch = FirebaseFirestore.instance.batch();

        for (final norm in part) {
          final rows = isbnToRows[norm] ?? const <Map<String, dynamic>>[];
          if (rows.isEmpty) continue;

          var totalQty = 0;
          for (final r in rows) {
            final q = r['quantity'];
            if (q is int) {
              totalQty += q;
            } else if (q is double) {
              totalQty += q.round();
            } else {
              totalQty += int.tryParse(q?.toString() ?? '') ?? 1;
            }
          }
          if (totalQty < 1) totalQty = 1;

          // metadata: lấy từ dòng đầu (giống trước), nhưng luôn chuẩn hoá isbn
          final src = Map<String, dynamic>.from(rows.first);
          src['isbn'] = norm;
          src.remove('_importGenreName');
          src.remove('_importGenreId');

          final coverUrl = _firstHttpImageUrlFromRows(rows);
          src.remove('imageUrl');

          // Chọn target doc:
          // - Nếu docId chuẩn hoá đã tồn tại -> dùng docId đó.
          // - Else nếu có doc cũ theo field isbn -> update doc đó.
          // - Else tạo doc mới theo docId chuẩn hoá.
          final idRef = col.doc(_bookDocIdFromIsbn(norm));
          final hasId = isbnIdExists[norm] == true;
          final existingByField = isbnToExistingDocRef[norm];
          final target = hasId ? idRef : (existingByField ?? idRef);

          final isNew = !hasId && existingByField == null;

          final patch = <String, dynamic>{
            ...src,
            'quantity': FieldValue.increment(totalQty),
            'availableQuantity': FieldValue.increment(totalQty),
            'isAvailable': true,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          if (coverUrl != null) {
            patch['imageUrl'] = coverUrl;
          }
          if (isNew) {
            patch['createdAt'] = FieldValue.serverTimestamp();
            patch['totalBorrowCount'] = src['totalBorrowCount'] ?? 0;
            if (coverUrl == null) patch['imageUrl'] = '';
          }

          batch.set(target, patch, SetOptions(merge: true));
          written += rows.length;
        }

        await batch.commit();
      }
    } catch (e) {
      return (written: written, error: e.toString());
    }

    // 3) Các dòng không có ISBN: vẫn tạo doc mới (auto-id) như trước.
    const batchChunk = 450;
    try {
      for (var i = 0; i < noIsbnRows.length; i += batchChunk) {
        final end = (i + batchChunk > noIsbnRows.length)
            ? noIsbnRows.length
            : i + batchChunk;
        final batch = FirebaseFirestore.instance.batch();
        for (var j = i; j < end; j++) {
          final doc = col.doc();
          batch.set(doc, noIsbnRows[j]);
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
