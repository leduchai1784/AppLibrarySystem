import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Lưu bytes vào thư mục ứng dụng, trả về đường dẫn tuyệt đối (để mở bằng OpenFilex).
Future<String?> saveLibraryReportToAppDir(
  List<int> bytes,
  String filename,
) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
