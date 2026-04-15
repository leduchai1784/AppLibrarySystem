import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile/desktop: lưu tạm và mở sheet chia sẻ.
Future<void> shareBytesAsFile(List<int> bytes, String filename, {String? mimeType}) async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/$filename';
  final file = File(path);
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(path, mimeType: mimeType, name: filename)],
      subject: filename,
    ),
  );
}
