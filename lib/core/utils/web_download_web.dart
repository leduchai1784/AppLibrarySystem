import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

void triggerWebDownload(String filename, String content) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json;charset=utf-8');
  _downloadBlob(filename, blob);
}

void triggerWebDownloadBytes(
  String filename,
  List<int> bytes,
  String mimeType,
) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final blob = html.Blob([data], mimeType);
  _downloadBlob(filename, blob);
}

void _downloadBlob(String filename, html.Blob blob) {
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // Revoke ngay có thể cắt tải trên một số trình duyệt; để URL sống thêm một nhịp.
  unawaited(
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      html.Url.revokeObjectUrl(url);
    }),
  );
}
