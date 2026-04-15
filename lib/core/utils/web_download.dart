import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as dow;

void triggerWebDownload(String filename, String content) =>
    dow.triggerWebDownload(filename, content);

void triggerWebDownloadBytes(String filename, List<int> bytes, String mimeType) =>
    dow.triggerWebDownloadBytes(filename, bytes, mimeType);
