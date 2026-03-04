import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình thêm / cập nhật sách (Admin) - giao diện hoàn chỉnh
class AddEditBookScreen extends StatefulWidget {
  const AddEditBookScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Công nghệ';
  final _categories = ['Công nghệ', 'Kinh tế', 'Văn học', 'Khoa học', 'Lịch sử', 'Giáo dục'];
  String? _docId;
  bool _initializedFromArgs = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu chuyển từ màn hình danh sách / chi tiết sang khi ở chế độ sửa
    if (widget.isEdit && !_initializedFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : null;
      if (map != null) {
        _docId = map['id'] as String?;
        _titleController.text = map['title']?.toString() ?? '';
        _authorController.text = map['author']?.toString() ?? '';
        _selectedCategory = map['category']?.toString() ?? _selectedCategory;
        _isbnController.text = map['isbn']?.toString() ?? '';
        _quantityController.text = map['quantity']?.toString() ?? '1';
        _descriptionController.text = map['description']?.toString() ?? '';
      }
      _initializedFromArgs = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Cập nhật sách' : 'Thêm sách mới'),
        actions: [
          if (widget.isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirm(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin cơ bản
              _SectionTitle(title: 'Thông tin cơ bản', icon: Icons.info_outline),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Tên sách',
                hint: 'Nhập tên sách',
                controller: _titleController,
                prefixIcon: Icons.menu_book,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Tác giả',
                hint: 'Nhập tên tác giả',
                controller: _authorController,
                prefixIcon: Icons.person_outline,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Danh mục',
                value: _selectedCategory,
                items: _categories,
                onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Mã ISBN',
                hint: '978-xxx-xxx-xxx',
                controller: _isbnController,
                prefixIcon: Icons.tag,
                keyboardType: TextInputType.text,
              ),

              // Số lượng
              const SizedBox(height: 24),
              _SectionTitle(title: 'Quản lý kho', icon: Icons.inventory_2_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Số lượng',
                hint: '0',
                controller: _quantityController,
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                required: true,
              ),

              // Mô tả
              const SizedBox(height: 24),
              _SectionTitle(title: 'Mô tả', icon: Icons.description_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Mô tả sách',
                hint: 'Mô tả ngắn về nội dung cuốn sách...',
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    await _onSubmit(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(widget.isEdit ? 'CẬP NHẬT SÁCH' : 'THÊM SÁCH'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final description = _descriptionController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    final data = <String, dynamic>{
      'title': title,
      'author': author,
      'category': _selectedCategory,
      'categoryId': _selectedCategory, // tạm dùng tên danh mục làm id
      'isbn': isbn,
      'description': description,
      'quantity': quantity,
      'isAvailable': quantity > 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final booksRef = FirebaseFirestore.instance.collection('books');

    try {
      if (widget.isEdit && _docId != null) {
        // Giữ nguyên availableQuantity hiện tại để tránh sai lệch mượn trả
        final docSnap = await booksRef.doc(_docId).get();
        final current = docSnap.data() as Map<String, dynamic>?;
        final currentAvailable = current?['availableQuantity'];
        if (currentAvailable != null) {
          data['availableQuantity'] = currentAvailable;
        }
        await booksRef.doc(_docId).update(data);
      } else {
        await booksRef.add({
          ...data,
          'availableQuantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
          'totalBorrowCount': 0,
          'imageUrl': '',
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Cập nhật sách thành công' : 'Thêm sách thành công'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu sách: $e')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.caption),
            if (required) const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20),
          ),
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
          items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa sách này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              if (_docId == null) {
                Navigator.pop(context);
                return;
              }
              try {
                await FirebaseFirestore.instance.collection('books').doc(_docId).delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa sách')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa sách: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}
