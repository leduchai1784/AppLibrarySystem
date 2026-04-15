import 'package:cloud_firestore/cloud_firestore.dart';

/// Đảm bảo danh mục có trong `categories` trước / kèm khi gán sách — trùng `name` (chuỗi) thì bỏ qua.
class CategoryEnsureService {
  CategoryEnsureService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Nếu [name] rỗng sau trim thì không làm gì.
  /// Nếu chưa có document nào `name` == [name] thì `add` giống màn Quản lý danh mục.
  static Future<void> ensureByName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final col = _db.collection('categories');
    final existing = await col.where('name', isEqualTo: trimmed).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    await col.add({
      'name': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Gom mọi giá trị `category` (chuỗi) từ map sách, gọi [ensureByName] từng tên duy nhất.
  static Future<void> ensureForBookMaps(Iterable<Map<String, dynamic>> books) async {
    final seen = <String>{};
    for (final b in books) {
      final raw = b['category'];
      if (raw == null) continue;
      final s = raw.toString().trim();
      if (s.isEmpty || !seen.add(s)) continue;
      await ensureByName(s);
    }
  }
}
