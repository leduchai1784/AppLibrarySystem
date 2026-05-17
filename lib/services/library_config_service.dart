import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/borrow_policy.dart';

/// Đọc `library_settings/config` — chỉnh qua [LibraryBusinessSettingsScreen] (admin).
class LibraryConfigService {
  LibraryConfigService._();

  static const String collection = 'library_settings';
  static const String configDocId = 'config';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get configRef =>
      _db.collection(collection).doc(configDocId);

  static Future<Map<String, dynamic>> getConfigMap() async {
    final snap = await configRef.get();
    return snap.data() ?? {};
  }

  /// Gợi ý ngày mượn (7–14) lưu trong Firestore.
  static Future<int> loanDaysSuggested() async {
    final m = await getConfigMap();
    final v = m['loanDays'];
    if (v is int && v > 0) {
      return BorrowPolicy.clampConfigToSuggestedRange(v);
    }
    return BorrowPolicy.defaultLoanDays;
  }

  /// Số phiếu đang mượn tối đa cho một user (mặc định 5).
  static Future<int> maxActiveBorrowsPerUser() async {
    final m = await getConfigMap();
    final v = m['maxActiveBorrowsPerUser'];
    if (v is int && v > 0) {
      return v.clamp(1, 99);
    }
    return 5;
  }

  /// Base URL FastAPI (admin cấu hình trong [LibraryBusinessSettingsScreen]), ví dụ `http://10.10.10.113:8000`.
  static Future<String?> fastApiBaseUrl() async {
    final m = await getConfigMap();
    return fastApiBaseUrlFromMap(m);
  }

  static String? fastApiBaseUrlFromMap(Map<String, dynamic> m) {
    final v = m['fastApiBaseUrl'];
    if (v is String) {
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  /// Base URL dùng cho gợi ý: Firestore nếu có, không thì [fallback].
  static String effectiveFastApiBaseUrl(
    Map<String, dynamic> m,
    String fallback,
  ) {
    final b = fastApiBaseUrlFromMap(m);
    return (b != null && b.trim().isNotEmpty) ? b.trim() : fallback;
  }

  /// Cấu hình gọi FastAPI gợi ý theo user (`GET …/recommend/me?top_k=…`).
  static Future<FastApiRecommendationsSettings>
  fastApiRecommendationsSettings() async {
    final m = await getConfigMap();
    return FastApiRecommendationsSettings.fromConfigMap(m);
  }

  /// Cấu hình Cloudinary (unsigned upload) để lưu ảnh bìa sách.
  static Future<CloudinaryUploadSettings> cloudinaryUploadSettings() async {
    final m = await getConfigMap();
    return CloudinaryUploadSettings.fromConfigMap(m);
  }
}

/// Đọc từ `library_settings/config` — khớp FastAPI `GET /recommend/me?top_k=…` + header tuỳ chọn `X-Dev-Uid`.
class FastApiRecommendationsSettings {
  FastApiRecommendationsSettings({
    required this.resourcePath,
    required this.topK,
    this.devBypassUid,
    required this.bookSimilarPath,
    required this.bookSimilarTopK,
  });

  /// Path sau base URL, mặc định `recommend/me`.
  final String resourcePath;

  /// Query `top_k` (1–50), mặc định 10.
  final int topK;

  /// Gửi header `X-Dev-Uid` khi server bật `DEV_AUTH_BYPASS` (chỉ môi trường dev).
  final String? devBypassUid;

  /// `GET …/{bookSimilarPath}?book_id=…&top_k=…` — mặc định `recommend`.
  final String bookSimilarPath;

  /// `top_k` cho gợi ý theo một sách (1–50), mặc định 5.
  final int bookSimilarTopK;

  static const String defaultResourcePath = 'recommend/me';
  static const String defaultBookSimilarPath = 'recommend';

  factory FastApiRecommendationsSettings.fromConfigMap(Map<String, dynamic> m) {
    return FastApiRecommendationsSettings(
      resourcePath: _resourcePathFrom(m),
      topK: _topKFrom(m),
      devBypassUid: _devUidFrom(m),
      bookSimilarPath: _bookSimilarPathFrom(m),
      bookSimilarTopK: _bookSimilarTopKFrom(m),
    );
  }

  static String _resourcePathFrom(Map<String, dynamic> m) {
    final v = m['fastApiRecommendationsPath'];
    if (v is String) {
      var t = v.trim();
      while (t.startsWith('/')) {
        t = t.substring(1);
      }
      if (t.isNotEmpty) return t;
    }
    return defaultResourcePath;
  }

  static int _topKFrom(Map<String, dynamic> m) {
    final v = m['fastApiRecommendationsTopK'];
    if (v is int && v > 0) return v.clamp(1, 50);
    if (v is num) return v.round().clamp(1, 50);
    return 10;
  }

  static String? _devUidFrom(Map<String, dynamic> m) {
    final v = m['fastApiDevUid'];
    if (v is String) {
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  static String _bookSimilarPathFrom(Map<String, dynamic> m) {
    final v = m['fastApiBookRecommendPath'];
    if (v is String) {
      var t = v.trim();
      while (t.startsWith('/')) {
        t = t.substring(1);
      }
      if (t.isNotEmpty) return t;
    }
    return defaultBookSimilarPath;
  }

  static int _bookSimilarTopKFrom(Map<String, dynamic> m) {
    final v = m['fastApiBookRecommendTopK'];
    if (v is int && v > 0) return v.clamp(1, 50);
    if (v is num) return v.round().clamp(1, 50);
    return 5;
  }
}

/// Đọc từ `library_settings/config` để upload ảnh không cần backend.
///
/// Keys:
/// - `cloudinaryCloudName` (string)
/// - `cloudinaryUploadPreset` (string, unsigned preset)
/// - `cloudinaryFolder` (string, optional) ví dụ `library/books`
class CloudinaryUploadSettings {
  CloudinaryUploadSettings({
    required this.cloudName,
    required this.uploadPreset,
    this.folder,
  });

  final String cloudName;
  final String uploadPreset;
  final String? folder;

  bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;

  factory CloudinaryUploadSettings.fromConfigMap(Map<String, dynamic> m) {
    String readStr(String key) {
      final v = m[key];
      if (v is String) return v.trim();
      return '';
    }

    String? readOpt(String key) {
      final s = readStr(key);
      return s.isEmpty ? null : s;
    }

    return CloudinaryUploadSettings(
      cloudName: readStr('cloudinaryCloudName'),
      uploadPreset: readStr('cloudinaryUploadPreset'),
      folder: readOpt('cloudinaryFolder'),
    );
  }
}
