import 'package:cloud_firestore/cloud_firestore.dart';

/// Gắn `genreId` / `authorId` khi nhập Excel: tạo hoặc tìm document theo tên trong `genres` / `authors`.
class GenreAuthorResolveService {
  GenreAuthorResolveService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String?> _genreIdForNameOrCreate(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final col = _db.collection('genres');
    final existing = await col.where('name', isEqualTo: trimmed).limit(1).get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final ref = await col.add({
      'name': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<String?> _authorIdForNameOrCreate(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final col = _db.collection('authors');
    final existing = await col.where('name', isEqualTo: trimmed).limit(1).get();
    if (existing.docs.isNotEmpty) return existing.docs.first.id;
    final ref = await col.add({
      'name': trimmed,
      'description': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Xóa khóa tạm `_importGenreName` / `_importGenreId`, ghi `genreId` / `authorId` vào map sách.
  static Future<void> applyExcelLinks(List<Map<String, dynamic>> books) async {
    final genreNames = <String>{};
    for (final b in books) {
      final g = b['_importGenreName'] as String?;
      if (g != null && g.trim().isNotEmpty) genreNames.add(g.trim());
    }
    final genreNameToId = <String, String>{};
    for (final name in genreNames) {
      final id = await _genreIdForNameOrCreate(name);
      if (id != null) genreNameToId[name] = id;
    }

    final authorNames = <String>{};
    for (final b in books) {
      final a = (b['author'] as String?)?.trim();
      if (a != null && a.isNotEmpty) authorNames.add(a);
    }
    final authorNameToId = <String, String>{};
    for (final name in authorNames) {
      final id = await _authorIdForNameOrCreate(name);
      if (id != null) authorNameToId[name] = id;
    }

    for (final b in books) {
      final directGid = (b.remove('_importGenreId') as String?)?.trim();
      final gn = (b.remove('_importGenreName') as String?)?.trim();
      if (directGid != null && directGid.isNotEmpty) {
        b['genreId'] = directGid;
      } else if (gn != null && gn.isNotEmpty) {
        final id = genreNameToId[gn];
        if (id != null) b['genreId'] = id;
      }

      final au = (b['author'] as String?)?.trim() ?? '';
      if (au.isNotEmpty) {
        final aid = authorNameToId[au];
        if (aid != null) b['authorId'] = aid;
      }
    }
  }
}
