import 'dart:io';

import 'package:excel/excel.dart';

/// Generate a simple .xlsx template for importing books.
///
/// Columns match `BookExcelImportService` header mapping.
/// This script is intentionally standalone (no Flutter/l10n dependency).
void main(List<String> args) {
  final outPath = args.isNotEmpty ? args.first : 'book_import_template.xlsx';

  final excel = Excel.createExcel();
  final defaultName = excel.getDefaultSheet() ?? 'Sheet1';
  final sheetName = 'BookImportTemplate';
  if (defaultName != sheetName) {
    excel.rename(defaultName, sheetName);
  }
  final sheet = excel[sheetName];

  final headers = <String>[
    'title',
    'author',
    'category',
    'genre',
    'published_year',
    'isbn',
    'quantity',
    'description',
    'image_url',
  ];

  final sampleRows = <List<Object>>[
    [
      'Lập trình Dart',
      'Nguyễn Văn An',
      'Công nghệ',
      'Giáo trình',
      2022,
      '9786040011123',
      5,
      'Giáo trình cơ bản về Dart và ứng dụng Flutter.',
      'https://res.cloudinary.com/<cloud>/image/upload/<path>.jpg',
    ],
    [
      'Kinh tế vi mô',
      'Trần Thị Bình',
      'Kinh tế',
      'Kinh tế học',
      2020,
      '9786040022234',
      3,
      'Các khái niệm cung — cầu, thị trường cạnh tranh.',
      '',
    ],
  ];

  for (var c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
        TextCellValue(headers[c]);
  }
  for (var r = 0; r < sampleRows.length; r++) {
    final row = sampleRows[r];
    for (var c = 0; c < row.length; c++) {
      final v = row[c];
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
      );
      if (v is int) {
        cell.value = IntCellValue(v);
      } else {
        cell.value = TextCellValue(v.toString());
      }
    }
  }

  final bytes = excel.encode();
  if (bytes == null) {
    stderr.writeln('Failed to encode xlsx.');
    exitCode = 2;
    return;
  }

  final f = File(outPath);
  f.writeAsBytesSync(bytes, flush: true);
  stdout.writeln('Wrote template to: ${f.absolute.path}');
}
