import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Hiển thị ảnh bìa: URL `https://` hoặc [data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs) (base64 trong Firestore, không cần Storage).
///
/// Lưu ý hiệu năng:
/// - `data:image/...;base64,...` nếu decode trong `build()` sẽ bị lặp khi scroll (list recycle) → giật + giống "reload".
/// - Ảnh network có thể bị gọi lại `loadingBuilder` khi widget rebuild → flicker.
///
/// Ở đây ta:
/// - Cache bytes đã decode cho data URL (LRU đơn giản).
/// - Với ảnh network: hiển thị placeholder phía sau + fade-in frame đầu tiên, không show spinner mỗi rebuild.
final Map<String, Uint8List> _dataUrlBytesCache = <String, Uint8List>{};
const int _kDataUrlCacheMaxEntries = 80;

Uint8List? _getCachedDataUrlBytes(String dataUrl) {
  final hit = _dataUrlBytesCache.remove(dataUrl);
  if (hit != null) {
    // LRU: đẩy về cuối.
    _dataUrlBytesCache[dataUrl] = hit;
  }
  return hit;
}

void _putCachedDataUrlBytes(String dataUrl, Uint8List bytes) {
  // Đảm bảo LRU + giới hạn.
  _dataUrlBytesCache.remove(dataUrl);
  _dataUrlBytesCache[dataUrl] = bytes;
  while (_dataUrlBytesCache.length > _kDataUrlCacheMaxEntries) {
    _dataUrlBytesCache.remove(_dataUrlBytesCache.keys.first);
  }
}

String _optimizeCloudinaryUrl(String url, double targetWidth) {
  if (url.contains('cloudinary.com') && url.contains('/upload/')) {
    // Nếu url chưa có tham số biến đổi (chưa có thư mục dạng w_, h_, c_...) trước version tag
    if (!url.contains(RegExp(r'/upload/[a-z_0-9,]+/v\d+'))) {
      final w = targetWidth.isFinite && targetWidth > 0
          ? (targetWidth * 1.5).round()
          : 300;
      final transform = 'w_$w,c_limit,q_auto,f_auto';
      return url.replaceFirst('/upload/', '/upload/$transform/');
    }
  }
  return url;
}

/// Helper function to generate optimized Cloudinary thumbnail URL
String buildCloudinaryThumbUrl(String url, {int width = 80, int height = 120}) {
  if (url.contains('cloudinary.com') && url.contains('/upload/')) {
    if (!url.contains(RegExp(r'/upload/[a-z_0-9,]+/v\d+'))) {
      final transform = 'w_$width,h_$height,c_fill,q_auto,f_webp';
      return url.replaceFirst('/upload/', '/upload/$transform/');
    }
  }
  return url;
}

Widget buildBookCoverDisplay({
  required String imageRef,
  required double width,
  required double height,
  BorderRadius? borderRadius,
  Widget? placeholder,
}) {
  final url = imageRef.trim();
  final radius = borderRadius ?? BorderRadius.circular(12);
  final ph =
      placeholder ??
      Icon(Icons.menu_book, size: width * 0.45, color: Colors.white70);

  if (url.isEmpty) {
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Center(child: ph),
      ),
    );
  }

  if (url.startsWith('data:image')) {
    final comma = url.indexOf(',');
    if (comma <= 0 || comma >= url.length - 1) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: ph),
        ),
      );
    }
    try {
      final cached = _getCachedDataUrlBytes(url);
      final Uint8List bytes;
      if (cached != null) {
        bytes = cached;
      } else {
        bytes = base64Decode(url.substring(comma + 1));
        _putCachedDataUrlBytes(url, bytes);
      }
      return ClipRRect(
        borderRadius: radius,
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => SizedBox(
            width: width,
            height: height,
            child: Center(child: ph),
          ),
        ),
      );
    } catch (_) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: ph),
        ),
      );
    }
  }

  final placeholderBox = SizedBox(
    width: width,
    height: height,
    child: Center(child: ph),
  );
  return ClipRRect(
    borderRadius: radius,
    child: CachedNetworkImage(
      imageUrl: _optimizeCloudinaryUrl(url, width),
      width: width,
      height: height,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (_, __) => placeholderBox,
      errorWidget: (_, __, ___) => placeholderBox,
      memCacheWidth: width.isFinite ? (width * 2).round() : null,
      memCacheHeight: height.isFinite ? (height * 2).round() : null,
      filterQuality: FilterQuality.low,
    ),
  );
}
