import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Lỗi do quá thời gian chờ socket / request.
class ApiTimeoutException implements Exception {
  ApiTimeoutException(this.message);
  final String message;

  @override
  String toString() => 'ApiTimeoutException: $message';
}

/// HTTP status không nằm trong nhóm thành công (mặc định chỉ 200).
class ApiHttpException implements Exception {
  ApiHttpException({required this.statusCode, required this.bodyPreview});
  final int statusCode;
  final String bodyPreview;

  @override
  String toString() => 'ApiHttpException: status=$statusCode body=$bodyPreview';
}

/// Body không phải JSON hợp lệ hoặc không phải object (Map) khi dùng [getJsonObject].
class ApiParseException implements Exception {
  ApiParseException(this.message);
  final String message;

  @override
  String toString() => 'ApiParseException: $message';
}

/// Lớp HTTP mỏng, dùng lại cho mọi base URL (FastAPI, v.v.).
///
/// Bước 1: Chuẩn hoá [baseUrl] (bắt buộc có scheme http/https).
/// Bước 2: [get] ghép đường dẫn tương đối với base qua [Uri.resolve].
/// Bước 3: Gửi request với [timeout].
/// Bước 4: Kiểm tra status (mặc định chỉ chấp nhận 200).
/// Bước 5: [jsonDecode] và trả về cấu trúc Dart.
class ApiService {
  ApiService({
    required String baseUrl,
    this.timeout = const Duration(seconds: 15),
    this.acceptedSuccessStatuses = const {200},
    http.Client? httpClient,
  }) : _baseUri = _parseBaseUri(baseUrl),
       _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null;

  final Uri _baseUri;
  final Duration timeout;

  /// Các mã HTTP được coi là thành công (ví dụ thêm 201 nếu API của bạn cần).
  final Set<int> acceptedSuccessStatuses;
  final http.Client _client;
  final bool _ownsClient;

  /// Giải phóng [http.Client] nội bộ nếu [ApiService] tự tạo client.
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  static Uri _parseBaseUri(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must not be empty');
    }
    final uri = Uri.parse(trimmed);
    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'must start with http:// or https://',
      );
    }
    if (!uri.hasAuthority) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'must include host');
    }
    return uri;
  }

  /// Ghép [path] với base — dùng [pathSegments] để tránh lỗi `Uri.resolve` khi base có path
  /// nhưng thiếu `/` cuối (ví dụ `http://host:8000/api` + `recommendations`).
  Uri buildUri(String path, [Map<String, String>? queryParameters]) {
    final trimmed = path.startsWith('/') ? path.substring(1) : path;
    final extra = trimmed.split('/').where((s) => s.isNotEmpty).toList();
    final merged = <String>[..._baseUri.pathSegments, ...extra];
    var out = merged.isEmpty
        ? _baseUri
        : _baseUri.replace(pathSegments: merged);
    if (queryParameters == null || queryParameters.isEmpty) {
      return out;
    }
    return out.replace(queryParameters: queryParameters);
  }

  /// GET — trả raw body (UTF-8). Dùng khi response không phải JSON.
  Future<String> getString(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(path, queryParameters);
    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(timeout);
      _ensureSuccess(response);
      return response.body;
    } on TimeoutException {
      throw ApiTimeoutException('GET $uri exceeded $timeout');
    } on SocketException catch (e) {
      throw ApiTimeoutException('Network error: ${e.message}');
    } on ApiHttpException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiTimeoutException('Client error: ${e.message}');
    }
  }

  /// GET — parse JSON (Map, List, primitive). Dùng khi không chắc kiểu gốc.
  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final body = await getString(
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw ApiParseException('Invalid JSON: ${e.message}');
    }
  }

  /// GET — parse JSON và yêu cầu object ở gốc (`{ ... }`).
  Future<Map<String, dynamic>> getJsonObject(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final decoded = await getJson(
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    throw ApiParseException(
      'Expected JSON object at root, got ${decoded.runtimeType}',
    );
  }

  void _ensureSuccess(http.Response response) {
    if (acceptedSuccessStatuses.contains(response.statusCode)) {
      return;
    }
    final preview = response.body.length > 200
        ? '${response.body.substring(0, 200)}…'
        : response.body;
    throw ApiHttpException(
      statusCode: response.statusCode,
      bodyPreview: preview,
    );
  }
}
