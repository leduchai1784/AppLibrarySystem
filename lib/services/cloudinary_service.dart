import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'library_config_service.dart';

class CloudinaryService {
  CloudinaryService._();

  static Uri _uploadUri(String cloudName) {
    final cn = cloudName.trim();
    return Uri.parse('https://api.cloudinary.com/v1_1/$cn/image/upload');
  }

  /// Upload ảnh bìa lên Cloudinary theo cấu hình `library_settings/config`.
  ///
  /// Trả về `secure_url` nếu thành công, ngược lại ném exception (để UI hiển thị).
  static Future<String> uploadBookCoverBytes({
    required Uint8List bytes,
    required String filename,
    String? folderOverride,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final cfg = await LibraryConfigService.cloudinaryUploadSettings();
    if (!cfg.isConfigured) {
      throw StateError(
        'Cloudinary chưa được cấu hình (cloudName/uploadPreset).',
      );
    }
    if (cfg.cloudName.trim().toLowerCase() ==
        cfg.uploadPreset.trim().toLowerCase()) {
      throw StateError(
        'Cloudinary cấu hình sai: Cloud Name đang trùng Upload Preset. '
        'Hãy nhập Cloud Name thật trong Cloudinary Dashboard (không phải tên preset).',
      );
    }

    final uri = _uploadUri(cfg.cloudName);
    final req = http.MultipartRequest('POST', uri);
    req.fields['upload_preset'] = cfg.uploadPreset.trim();

    final folder = (folderOverride?.trim().isNotEmpty ?? false)
        ? folderOverride!.trim()
        : (cfg.folder?.trim().isNotEmpty ?? false)
        ? cfg.folder!.trim()
        : null;
    if (folder != null) {
      req.fields['folder'] = folder;
    }

    final safeName = filename.trim().isEmpty ? 'cover.jpg' : filename.trim();
    req.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: safeName),
    );

    final streamed = await req.send().timeout(timeout);
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw StateError(
        'Cloudinary upload failed (${streamed.statusCode}). '
        'Kiểm tra Cloud Name + Upload Preset (Unsigned) trong Cài đặt thư viện. '
        'Response: $body',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw StateError('Cloudinary response invalid: $body');
    }
    final m = decoded.map((k, v) => MapEntry(k.toString(), v));
    final url = (m['secure_url'] ?? m['url'] ?? '').toString().trim();
    if (url.isEmpty) {
      throw StateError('Cloudinary không trả về secure_url.');
    }
    return url;
  }
}
