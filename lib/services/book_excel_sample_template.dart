import 'package:excel/excel.dart';

import '../gen/l10n/app_localizations.dart';

/// File Excel mẫu: tiêu đề cột theo ngôn ngữ + 5 dòng sách (tương thích [BookExcelImportService]).
class BookExcelSampleTemplate {
  BookExcelSampleTemplate._();

  /// Trả về nội dung .xlsx hoặc null nếu không encode được.
  static List<int>? buildLocalizedSampleBytes(AppLocalizations t) {
    final excel = Excel.createExcel();
    final defaultName = excel.getDefaultSheet();
    final sheetName = t.excelSampleSheetName;
    if (defaultName != null && defaultName != sheetName) {
      excel.rename(defaultName, sheetName);
    }
    final sheet = excel[sheetName];

    final headers = [
      t.excelSampleColTitle,
      t.excelSampleColAuthor,
      t.excelSampleColCategory,
      t.excelSampleColGenre,
      t.excelSampleColPublishedYear,
      t.excelSampleColIsbn,
      t.excelSampleColQuantity,
      t.excelSampleColDescription,
    ];

    final rows = <List<Object>>[
      [
        'Lập trình Dart',
        'Nguyễn Văn An',
        'Công nghệ',
        'Giáo trình',
        2022,
        '9786040011123',
        5,
        'Giáo trình cơ bản về Dart và ứng dụng Flutter.',
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
      ],
      [
        'Những người khốn khổ',
        'Victor Hugo',
        'Văn học',
        'Tiểu thuyết',
        2018,
        '9786040033345',
        8,
        'Tác phẩm kinh điển văn học Pháp (bản dịch).',
      ],
      [
        'Lịch sử Việt Nam hiện đại',
        'Lê Văn Cường',
        'Lịch sử',
        'Lịch sử',
        2019,
        '9786040044456',
        4,
        'Từ thế kỷ XIX đến đầu thế kỷ XX.',
      ],
      [
        'Sức khỏe sinh viên',
        'Phạm Minh Dũng',
        'Giáo dục',
        'Đời sống',
        2021,
        '9786040055567',
        6,
        'Dinh dưỡng, vận động và phòng bệnh thường gặp.',
      ],
    ];

    for (var c = 0; c < headers.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
          .value = TextCellValue(headers[c]);
    }

    for (var r = 0; r < rows.length; r++) {
      final data = rows[r];
      for (var c = 0; c < data.length; c++) {
        final v = data[c];
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        if (v is int) {
          cell.value = IntCellValue(v);
        } else {
          cell.value = TextCellValue(v.toString());
        }
      }
    }

    return excel.encode();
  }
}
