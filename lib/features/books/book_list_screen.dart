import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';

/// Màn hình danh sách sách (Admin) - giao diện hoàn chỉnh
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  bool _isGridView = true;
  String _sortBy = 'Tên sách';
  final _categories = ['Tất cả', 'Công nghệ', 'Kinh tế', 'Văn học', 'Khoa học'];
  final _sortOptions = ['Tên sách', 'Tác giả', 'Danh mục', 'Số lượng còn', 'Ngày thêm'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sách'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (context) => _sortOptions
                .map((o) => PopupMenuItem(value: o, child: Text(o)))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thống kê nhanh
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('books').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text('Không thể tải dữ liệu sách');
                }

                final docs = snapshot.data?.docs ?? [];
                final allBooks = docs.map(_BookItem.fromDoc).toList();

                final totalBooks = allBooks.fold<int>(0, (s, b) => s + b.quantity);
                final totalAvailable = allBooks.fold<int>(0, (s, b) => s + b.available);
                final totalBorrowed = totalBooks - totalAvailable;

                return Row(
                  children: [
                    _StatItem(label: 'Tổng sách', value: '$totalBooks', color: AppColors.primary),
                    const SizedBox(width: 16),
                    _StatItem(label: 'Có sẵn', value: '$totalAvailable', color: AppColors.success),
                    const SizedBox(width: 16),
                    _StatItem(label: 'Đang mượn', value: '$totalBorrowed', color: AppColors.secondary),
                  ],
                );
              },
            ),
          ),

          // Tìm kiếm & lọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sách theo tên, tác giả, ISBN...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((c) {
                      final selected = _selectedCategory == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedCategory = c),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Sắp xếp: $_sortBy', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('books').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Không thể tải danh sách sách'));
                }

                final docs = snapshot.data?.docs ?? [];
                var books = docs.map(_BookItem.fromDoc).toList();

                // Lọc theo danh mục (tạm dùng tên danh mục)
                if (_selectedCategory != 'Tất cả') {
                  books = books.where((b) => b.category == _selectedCategory).toList();
                }

                // Lọc theo ô tìm kiếm
                final query = _searchController.text.trim().toLowerCase();
                if (query.isNotEmpty) {
                  books = books.where((b) {
                    return b.title.toLowerCase().contains(query) ||
                        b.author.toLowerCase().contains(query) ||
                        b.isbn.toLowerCase().contains(query);
                  }).toList();
                }

                // Sắp xếp
                books.sort((a, b) {
                  switch (_sortBy) {
                    case 'Tên sách':
                      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
                    case 'Tác giả':
                      return a.author.toLowerCase().compareTo(b.author.toLowerCase());
                    case 'Danh mục':
                      return a.category.toLowerCase().compareTo(b.category.toLowerCase());
                    case 'Số lượng còn':
                      return b.available.compareTo(a.available);
                    case 'Ngày thêm':
                      final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                      final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                      return bd.compareTo(ad);
                    default:
                      return 0;
                  }
                });

                if (books.isEmpty) {
                  return const Center(child: Text('Chưa có sách nào'));
                }

                return _isGridView ? _buildGridView(books, theme) : _buildListView(books, theme);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addBook),
        icon: const Icon(Icons.add),
        label: const Text('Thêm sách'),
      ),
    );
  }

  Widget _buildListView(List<_BookItem> books, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final bookMap = _bookToMap(book);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 48,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book, color: AppColors.primary, size: 28),
            ),
            title: Text(book.title, style: AppTextStyles.h3),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${book.author} • ${book.category}', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  'ISBN: ${book.isbn} | Còn lại: ${book.available}/${book.quantity}',
                  style: AppTextStyles.small.copyWith(
                    color: book.available > 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') Navigator.pushNamed(context, AppRoutes.editBook, arguments: bookMap);
                if (v == 'detail') Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: bookMap);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'detail', child: Text('Xem chi tiết')),
                const PopupMenuItem(value: 'edit', child: Text('Cập nhật')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: AppColors.error))),
              ],
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: bookMap),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<_BookItem> books, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final bookMap = _bookToMap(book);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: bookMap),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu_book, color: AppColors.primary, size: 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(book.category, style: AppTextStyles.small.copyWith(color: AppColors.primary)),
                      ),
                      const Spacer(),
                      Text(
                        '${book.available}/${book.quantity}',
                        style: AppTextStyles.small.copyWith(
                          color: book.available > 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _bookToMap(_BookItem book) => {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'category': book.category,
        'isbn': book.isbn,
        'quantity': book.quantity,
        'available': book.available,
      };
}

class _BookItem {
  final String id, title, author, category, isbn;
  final int quantity, available;
  final DateTime? createdAt;
  _BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.isbn,
    required this.quantity,
    required this.available,
    required this.createdAt,
  });

  factory _BookItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final quantity = (data['quantity'] ?? 0) as int;
    final available = (data['availableQuantity'] ?? data['available'] ?? quantity) as int;
    return _BookItem(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      author: (data['author'] ?? '') as String,
      category: (data['category'] ?? data['categoryId'] ?? 'Khác') as String,
      isbn: (data['isbn'] ?? '') as String,
      quantity: quantity,
      available: available,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}
