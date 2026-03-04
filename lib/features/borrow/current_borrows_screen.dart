import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình sách đang mượn (Sinh viên) - UI only
class CurrentBorrowsScreen extends StatelessWidget {
  const CurrentBorrowsScreen({super.key, this.embedInTab = false});

  /// Khi true: chỉ trả về nội dung (dùng nhúng trong tab), không dùng Scaffold
  final bool embedInTab;

  @override
  Widget build(BuildContext context) {
    final mockBorrows = [
      _CurrentBorrow(bookTitle: 'Flutter cơ bản', dueDate: '05/03/2026', daysLeft: 5),
      _CurrentBorrow(bookTitle: 'Dart programming', dueDate: '10/03/2026', daysLeft: 10),
    ];

    final body = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockBorrows.length,
        itemBuilder: (context, index) {
          final b = mockBorrows[index];
          final warning = b.daysLeft <= 3;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: warning ? AppColors.warning.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.menu_book, color: warning ? AppColors.warning : AppColors.primary),
              ),
              title: Text(b.bookTitle, style: AppTextStyles.h3),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hạn trả: ${b.dueDate}', style: AppTextStyles.caption),
                  Text(
                    'Còn ${b.daysLeft} ngày',
                    style: AppTextStyles.small.copyWith(
                      color: warning ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
              trailing: OutlinedButton(
                onPressed: () {},
                child: const Text('Gia hạn'),
              ),
            ),
          );
        },
    );

    if (embedInTab) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Sách đang mượn')),
      body: body,
    );
  }
}

class _CurrentBorrow {
  final String bookTitle, dueDate;
  final int daysLeft;
  _CurrentBorrow({required this.bookTitle, required this.dueDate, required this.daysLeft});
}
