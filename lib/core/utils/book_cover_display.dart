import 'dart:convert';
import 'dart:typed_data';

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

Widget buildBookCoverDisplay({
  required String imageRef,
  required double width,
  required double height,
  BorderRadius? borderRadius,
  Widget? placeholder,
}) {
  final url = imageRef.trim();
  final radius = borderRadius ?? BorderRadius.circular(12);
  final ph = placeholder ??
      Icon(Icons.menu_book, size: width * 0.45, color: Colors.white70);

  if (url.isEmpty) {
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: Center(child: ph)),
    );
  }

  if (url.startsWith('data:image')) {
    final comma = url.indexOf(',');
    if (comma <= 0 || comma >= url.length - 1) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(width: width, height: height, child: Center(child: ph)),
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
          errorBuilder: (_, __, ___) => SizedBox(width: width, height: height, child: Center(child: ph)),
        ),
      );
    } catch (_) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(width: width, height: height, child: Center(child: ph)),
      );
    }
  }

  final placeholderBox = SizedBox(width: width, height: height, child: Center(child: ph));
  return ClipRRect(
    borderRadius: radius,
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        // Placeholder phía sau để tránh nhảy layout / trắng màn khi ảnh đang resolve.
        placeholderBox,
        Positioned.fill(
          child: Image(
            image: NetworkImage(url),
            width: width,
            height: height,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => placeholderBox,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              if (frame == null) {
                // Chưa có frame đầu tiên: giữ placeholder phía sau.
                return const SizedBox.shrink();
              }
              return AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: child,
              );
            },
          ),
        ),
      ],
    ),
  );
}
