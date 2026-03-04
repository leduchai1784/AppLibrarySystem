import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';

/// Màn hình chi tiết sách - giao diện hoàn chỉnh
class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = ModalRoute.of(context)?.settings.arguments;
    final map = book is Map ? book : null;
    final id = map?['id'] as String?;
    final title = map?['title'] ?? 'Sách mẫu';
    final author = map?['author'] ?? 'Tác giả';
    final category = map?['category'] ?? 'Công nghệ';
    final isbn = map?['isbn'] ?? '978-xxx-xxx-xxx';
    final quantity = map != null && map['quantity'] != null ? map['quantity'] as int : 5;
    final available = map != null && map['available'] != null ? map['available'] as int : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sách'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editBook, arguments: map),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _showDeleteConfirm(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bìa sách & thông tin chính
            Center(
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_book, size: 80, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Tác giả: $author', style: AppTextStyles.body),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(category, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thống kê số lượng
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(label: 'Tổng số lượng', value: '$quantity', icon: Icons.inventory),
                    const Divider(),
                    _InfoRow(label: 'Đang có sẵn', value: '$available', icon: Icons.check_circle, valueColor: AppColors.success),
                    const Divider(),
                    _InfoRow(label: 'Đang được mượn', value: '${quantity - available}', icon: Icons.bookmark, valueColor: AppColors.secondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mã QR (bookId để quét tra cứu sách / tạo phiếu mượn)
            if (id != null && id.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_2, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Mã QR sách', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: id,
                            version: QrVersions.auto,
                            size: 160,
                            gapless: true,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Quét mã để tra cứu sách / tạo phiếu mượn',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'ID: $id',
                          style: AppTextStyles.small.copyWith(
                            color: theme.hintColor,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Thông tin bổ sung
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thông tin', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.tag, label: 'Mã ISBN', value: isbn),
                    const SizedBox(height: 8),
                    _InfoTile(icon: Icons.category, label: 'Danh mục', value: category),
                    const SizedBox(height: 8),
                    _InfoTile(icon: Icons.person, label: 'Tác giả', value: author),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mô tả', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      'Mô tả chi tiết về nội dung cuốn sách. Thông tin này sẽ được hiển thị đầy đủ khi có dữ liệu từ backend.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hành động
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.borrowCreate),
                icon: const Icon(Icons.add),
                label: const Text('TẠO PHIẾU MƯỢN'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editBook, arguments: map),
                icon: const Icon(Icons.edit),
                label: const Text('CẬP NHẬT THÔNG TIN'),
              ),
            ),
          ],
        ),
      ),
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
              final args = ModalRoute.of(context)?.settings.arguments;
              final map = args is Map ? args : null;
              final id = map?['id'] as String?;
              if (id == null) {
                Navigator.pop(context);
                return;
              }
              try {
                await FirebaseFirestore.instance.collection('books').doc(id).delete();
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(value, style: AppTextStyles.h3.copyWith(color: valueColor)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.small),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}
