import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

/// Widget placeholder dùng chung cho Admin và Student
class PlaceholderContent extends StatelessWidget {
  const PlaceholderContent({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onTap,
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }
}
