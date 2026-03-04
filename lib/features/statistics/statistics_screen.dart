import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình thống kê & báo cáo (Admin) - UI only
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = [
      _StatItem('Tổng số sách', '1.250', Icons.menu_book, AppColors.primary),
      _StatItem('Tổng người dùng', '320', Icons.people, AppColors.secondary),
      _StatItem('Tổng lượt mượn', '5.840', Icons.history, AppColors.success),
      _StatItem('Sách đang mượn', '156', Icons.bookmark, Colors.deepPurple),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê & báo cáo'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final s = stats[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, color: s.color, size: 32),
                        const SizedBox(height: 8),
                        Text(s.value, style: AppTextStyles.h1.copyWith(fontSize: 22)),
                        Text(s.label, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Sách mượn nhiều nhất', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...List.generate(5, (i) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text('Sách mẫu ${i + 1}', style: AppTextStyles.body),
                  subtitle: Text('${(i + 1) * 12} lượt mượn', style: AppTextStyles.caption),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text('Lượt mượn theo tháng', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [30.0, 50.0, 40.0, 60.0, 45.0, 55.0].asMap().entries.map((e) {
                        final m = 'T${e.key + 1}';
                        final h = e.value;
                        return Column(
                          children: [
                            Container(
                              width: 24,
                              height: h,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(m, style: AppTextStyles.small),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text('Biểu đồ lượt mượn (mẫu)', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download),
                label: const Text('Xuất báo cáo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  _StatItem(this.label, this.value, this.icon, this.color);
}
