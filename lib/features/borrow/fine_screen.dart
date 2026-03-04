import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình thanh toán phạt trả trễ - UI only
class FineScreen extends StatelessWidget {
  const FineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán phạt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng tiền phạt', style: AppTextStyles.h2),
                        Text('50.000 đ', style: AppTextStyles.h1.copyWith(color: AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Trả trễ 5 ngày x 10.000 đ/ngày', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Chi tiết phạt', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...List.generate(2, (i) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.menu_book, color: AppColors.primary),
                  title: Text('Sách mẫu ${i + 1}', style: AppTextStyles.body),
                  subtitle: Text('Trả trễ 2 ngày', style: AppTextStyles.caption),
                  trailing: Text('20.000 đ', style: AppTextStyles.body.copyWith(color: AppColors.error)),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text('Phương thức thanh toán', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Tiền mặt tại thư viện'),
              value: 'cash',
              groupValue: 'cash',
              onChanged: (_) {},
            ),
            RadioListTile<String>(
              title: const Text('Chuyển khoản'),
              value: 'transfer',
              groupValue: 'cash',
              onChanged: (_) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('THANH TOÁN 50.000 Đ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
