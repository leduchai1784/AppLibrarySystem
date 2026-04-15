// Chạy từ thư mục gốc project: dart run tool/write_danh_sach_10_xlsx.dart
import 'dart:io';

import 'package:excel/excel.dart';

void main() {
  final excel = Excel.createExcel();
  final defaultName = excel.getDefaultSheet();
  const sheetName = 'DanhSach';
  if (defaultName != null && defaultName != sheetName) {
    excel.rename(defaultName, sheetName);
  }
  final sheet = excel[sheetName];

  final headers = [
    'Tên sách',
    'Tác giả',
    'Danh mục',
    'Thể loại',
    'Năm xuất bản',
    'ISBN',
    'Số lượng',
    'Mô tả',
  ];
  final rows = <List<Object>>[
    ['Lập trình Dart', 'Nguyễn Văn An', 'Công nghệ', 'Giáo trình', 2022, '9786040011123', 5, 'Giáo trình Dart'],
    ['Kinh tế vi mô', 'Trần Thị Bình', 'Kinh tế', 'Kinh tế học', 2020, '9786040022234', 3, 'Cung cầu'],
    ['Những người khốn khổ', 'Victor Hugo', 'Văn học', 'Tiểu thuyết', 2018, '9786040033345', 8, 'Văn học Pháp'],
    ['Lịch sử Việt Nam', 'Lê Văn Cường', 'Lịch sử', 'Lịch sử', 2019, '9786040044456', 4, 'Hiện đại'],
    ['Sức khỏe sinh viên', 'Phạm Minh Dũng', 'Giáo dục', 'Đời sống', 2021, '9786040055567', 6, 'SKSV'],
    ['Cấu trúc dữ liệu', 'Hoàng Thị E', 'Công nghệ', 'Giáo trình', 2023, '9786040066678', 7, 'CTDL & GT'],
    ['Marketing căn bản', 'Đỗ Văn F', 'Kinh tế', 'Marketing', 2017, '9786040077789', 2, 'Mix marketing'],
    ['Truyện Kiều', 'Nguyễn Du', 'Văn học', 'Thơ ca', 1820, '9786040088890', 10, 'Tác phẩm kinh điển'],
    ['Vật lý đại cương', 'Bùi Thị G', 'Khoa học', 'Giáo trình', 2021, '9786040099901', 5, 'Đại học'],
    ['Tiếng Anh B1', 'John Smith', 'Giáo dục', 'Ngoại ngữ', 2019, '9786040100012', 9, 'Giao tiếp'],
  ];

  for (var c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value = TextCellValue(headers[c]);
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

  final out = excel.encode();
  if (out == null) {
    stderr.writeln('encode() trả về null');
    exit(1);
  }
  final f = File('lib/giaodien/danh_sach_10_sach.xlsx');
  f.createSync(recursive: true);
  f.writeAsBytesSync(out);
  stdout.writeln('Đã ghi ${f.path}');
}
