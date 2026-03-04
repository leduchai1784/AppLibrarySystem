import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình lịch sử mượn sách (Sinh viên) - UI only
class BorrowHistoryScreen extends StatelessWidget {
  const BorrowHistoryScreen({super.key, this.embedInTab = false});

  /// Khi true: chỉ trả về nội dung (dùng nhúng trong tab), không dùng Scaffold
  final bool embedInTab;

  @override
  Widget build(BuildContext context) {
    final mockHistory = List.generate(
      5,
      (i) => _BorrowRecord(
        bookTitle: 'Sách mẫu ${i + 1}',
        borrowDate: '01/02/2026',
        returnDate: '15/02/2026',
        status: i == 0 ? 'Đã trả' : (i == 1 ? 'Đang mượn' : 'Đã trả'),
        isLate: i == 2,
      ),
    );

    final body = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockHistory.length,
        itemBuilder: (context, index) {
          final r = mockHistory[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.primary),
              ),
              title: Text(r.bookTitle, style: AppTextStyles.h3),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mượn: ${r.borrowDate} - Trả: ${r.returnDate}', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusChip(status: r.status, isLate: r.isLate),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
    );

    if (embedInTab) return body;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử mượn sách'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: body,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isLate;

  const _StatusChip({required this.status, required this.isLate});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.success;
    if (status == 'Đang mượn') color = AppColors.primary;
    if (isLate) color = AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: AppTextStyles.small.copyWith(color: color)),
    );
  }
}

class _BorrowRecord {
  final String bookTitle, borrowDate, returnDate, status;
  final bool isLate;
  _BorrowRecord({
    required this.bookTitle,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    required this.isLate,
  });
}
