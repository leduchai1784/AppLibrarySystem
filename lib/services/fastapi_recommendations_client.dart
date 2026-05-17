import 'package:firebase_auth/firebase_auth.dart';

import 'api_service.dart';
import 'library_config_service.dart';

/// Một dòng gợi ý từ FastAPI (đã chuẩn hoá field cho UI).
class FastApiRecommendationBook {
  const FastApiRecommendationBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.imageUrl,
    required this.quantity,
    required this.availableQuantity,
  });

  final String id;
  final String title;
  final String author;
  final String category;
  final String imageUrl;
  final int quantity;
  final int availableQuantity;

  static int _readInt(Object? v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static FastApiRecommendationBook? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.map((k, v) => MapEntry(k.toString(), v));
    final id = (m['id'] ?? m['bookId'] ?? '').toString().trim();
    if (id.isEmpty) return null;

    final quantity = _readInt(m['quantity'], 0).clamp(0, 999999);
    final availableRaw = m['availableQuantity'] ?? m['available'] ?? quantity;
    final availableQuantity = _readInt(availableRaw, quantity).clamp(0, 999999);

    return FastApiRecommendationBook(
      id: id,
      title: (m['title'] ?? '').toString(),
      author: (m['author'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      imageUrl:
          (m['imageUrl'] ??
                  m['image_url'] ??
                  m['coverUrl'] ??
                  m['cover_url'] ??
                  m['thumbnailUrl'] ??
                  m['thumbnail_url'] ??
                  '')
              .toString(),
      quantity: quantity,
      availableQuantity: availableQuantity,
    );
  }
}

/// Gọi FastAPI gợi ý theo user đăng nhập.
///
/// **Endpoint (mặc định):** `GET {baseUrl}/recommend/me?top_k=<n>`
/// - Xác thực: `Authorization: Bearer <Firebase ID token>` (bắt buộc khi user đã đăng nhập).
/// - Dev (server `DEV_AUTH_BYPASS`): có thể thêm `X-Dev-Uid` qua cấu hình Firestore `fastApiDevUid`.
///
/// **JSON:** mảng gốc hoặc object có `books` / `items` / `recommendations` / `data` / `results` (mảng).
class FastApiRecommendationsClient {
  FastApiRecommendationsClient._();

  /// Gọi API; lỗi mạng/HTTP/parse được ném ra — UI có thể bắt và hiển thị lỗi.
  static Future<List<FastApiRecommendationBook>> fetch({
    required String baseUrl,
    String resourcePath = FastApiRecommendationsSettings.defaultResourcePath,
    int topK = 10,
    String? devBypassUid,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final tk = topK.clamp(1, 50);
    final query = <String, String>{'top_k': '$tk'};

    final headers = <String, String>{'Accept': 'application/json'};
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final dev = devBypassUid?.trim();
    if (dev != null && dev.isNotEmpty) {
      headers['X-Dev-Uid'] = dev;
    }

    var rel = resourcePath.trim();
    while (rel.startsWith('/')) {
      rel = rel.substring(1);
    }
    if (rel.isEmpty) rel = FastApiRecommendationsSettings.defaultResourcePath;

    final api = ApiService(baseUrl: baseUrl, timeout: timeout);
    try {
      final decoded = await api.getJson(
        rel,
        queryParameters: query,
        headers: headers,
      );
      return _parseList(decoded);
    } finally {
      api.dispose();
    }
  }

  /// Gợi ý theo **một** sách: `GET {baseUrl}/recommend?book_id=<id>&top_k=<n>` (path cấu hình được).
  static Future<List<FastApiRecommendationBook>> fetchByBookId({
    required String baseUrl,
    required String bookFirestoreId,
    String resourcePath = FastApiRecommendationsSettings.defaultBookSimilarPath,
    int topK = 5,
    String? devBypassUid,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final id = bookFirestoreId.trim();
    if (id.isEmpty) return const [];

    final user = FirebaseAuth.instance.currentUser;
    final tk = topK.clamp(1, 50);
    final query = <String, String>{'book_id': id, 'top_k': '$tk'};

    final headers = <String, String>{'Accept': 'application/json'};
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final dev = devBypassUid?.trim();
    if (dev != null && dev.isNotEmpty) {
      headers['X-Dev-Uid'] = dev;
    }

    var rel = resourcePath.trim();
    while (rel.startsWith('/')) {
      rel = rel.substring(1);
    }
    if (rel.isEmpty)
      rel = FastApiRecommendationsSettings.defaultBookSimilarPath;

    final api = ApiService(baseUrl: baseUrl, timeout: timeout);
    try {
      final decoded = await api.getJson(
        rel,
        queryParameters: query,
        headers: headers,
      );
      return _parseList(decoded);
    } finally {
      api.dispose();
    }
  }

  static List<FastApiRecommendationBook> _parseList(Object? decoded) {
    if (decoded is List) {
      return _mapList(decoded);
    }
    if (decoded is Map) {
      final m = decoded.map((k, v) => MapEntry(k.toString(), v));
      for (final key in <String>[
        'books',
        'items',
        'recommendations',
        'data',
        'results',
        'similar_books',
        'recommended_books',
      ]) {
        final v = m[key];
        if (v is List) return _mapList(v);
      }
    }
    return const [];
  }

  static List<FastApiRecommendationBook> _mapList(List<dynamic> list) {
    final out = <FastApiRecommendationBook>[];
    for (final e in list) {
      final b = FastApiRecommendationBook.tryParse(e);
      if (b != null) out.add(b);
    }
    return out;
  }
}
