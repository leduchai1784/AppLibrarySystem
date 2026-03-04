import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Màn hình thông báo (sắp đến hạn trả) - UI only
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockNotifications = [
      _NotificationItem(
        title: 'Sắp đến hạn trả sách',
        body: 'Sách "Flutter cơ bản" sẽ đến hạn vào 05/03/2026',
        time: '10 phút trước',
        type: 'due_soon',
      ),
      _NotificationItem(
        title: 'Nhắc nhở trả sách',
        body: 'Sách "Dart programming" còn 2 ngày đến hạn',
        time: '2 giờ trước',
        type: 'reminder',
      ),
      _NotificationItem(
        title: 'Xác nhận mượn sách',
        body: 'Phiếu mượn sách "Clean Code" đã được tạo thành công',
        time: 'Hôm qua',
        type: 'success',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Đánh dấu đã đọc'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final n = mockNotifications[index];
          Color iconColor = AppColors.primary;
          if (n.type == 'due_soon') iconColor = AppColors.warning;
          if (n.type == 'reminder') iconColor = AppColors.error;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(Icons.notifications, color: iconColor),
              ),
              title: Text(n.title, style: AppTextStyles.h3),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(n.body, style: AppTextStyles.body),
                  const SizedBox(height: 4),
                  Text(n.time, style: AppTextStyles.small),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final String title, body, time, type;
  _NotificationItem({required this.title, required this.body, required this.time, required this.type});
}
