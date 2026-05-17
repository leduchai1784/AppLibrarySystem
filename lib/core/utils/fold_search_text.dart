/// Chuẩn hóa chuỗi để so khớp tìm kiếm: chữ thường + bỏ dấu tiếng Việt (và vài ký tự Latin hay gặp).
String foldSearchText(String input) {
  final b = StringBuffer();
  for (final r in input.runes) {
    b.write(_foldChar(String.fromCharCode(r)));
  }
  return b.toString().toLowerCase();
}

/// Tách từ khóa (khoảng trắng), bỏ rỗng.
List<String> searchTokens(String rawQuery) {
  final folded = foldSearchText(rawQuery.trim());
  if (folded.isEmpty) return const [];
  return folded.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
}

/// [haystack] chứa [needle] sau khi bỏ dấu / chữ thường cả hai.
bool foldedContains(String haystack, String needle) {
  final q = foldSearchText(needle);
  if (q.isEmpty) return true;
  return foldSearchText(haystack).contains(q);
}

/// Mọi token trong [rawQuery] đều xuất hiện trong [haystack] (không phân biệt dấu).
bool foldedMatchesAllTokens(String haystack, String rawQuery) {
  final tokens = searchTokens(rawQuery);
  if (tokens.isEmpty) return true;
  final foldedHay = foldSearchText(haystack);
  for (final t in tokens) {
    if (!foldedHay.contains(t)) return false;
  }
  return true;
}

String _foldChar(String ch) {
  const map = <String, String>{
    // a
    'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
    'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
    'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
    'â': 'a', 'ă': 'a',
    'À': 'a', 'Á': 'a', 'Ả': 'a', 'Ã': 'a', 'Ạ': 'a',
    'Ầ': 'a', 'Ấ': 'a', 'Ẩ': 'a', 'Ẫ': 'a', 'Ậ': 'a',
    'Ằ': 'a', 'Ắ': 'a', 'Ẳ': 'a', 'Ẵ': 'a', 'Ặ': 'a',
    'Â': 'a', 'Ă': 'a',
    // d
    'đ': 'd', 'Đ': 'd',
    // e
    'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
    'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
    'ê': 'e',
    'È': 'e', 'É': 'e', 'Ẻ': 'e', 'Ẽ': 'e', 'Ẹ': 'e',
    'Ề': 'e', 'Ế': 'e', 'Ể': 'e', 'Ễ': 'e', 'Ệ': 'e',
    'Ê': 'e',
    // i
    'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
    'Ì': 'i', 'Í': 'i', 'Ỉ': 'i', 'Ĩ': 'i', 'Ị': 'i',
    // o
    'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
    'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
    'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
    'ô': 'o', 'ơ': 'o',
    'Ò': 'o', 'Ó': 'o', 'Ỏ': 'o', 'Õ': 'o', 'Ọ': 'o',
    'Ồ': 'o', 'Ố': 'o', 'Ổ': 'o', 'Ỗ': 'o', 'Ộ': 'o',
    'Ờ': 'o', 'Ớ': 'o', 'Ở': 'o', 'Ỡ': 'o', 'Ợ': 'o',
    'Ô': 'o', 'Ơ': 'o',
    // u
    'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
    'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
    'ư': 'u',
    'Ù': 'u', 'Ú': 'u', 'Ủ': 'u', 'Ũ': 'u', 'Ụ': 'u',
    'Ừ': 'u', 'Ứ': 'u', 'Ử': 'u', 'Ữ': 'u', 'Ự': 'u',
    'Ư': 'u',
    // y
    'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
    'Ỳ': 'y', 'Ý': 'y', 'Ỷ': 'y', 'Ỹ': 'y', 'Ỵ': 'y',
  };
  return map[ch] ?? ch;
}
