import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

/// Tab quét QR Code sách - dùng chung Admin và Sinh viên
class ScanBookTab extends StatelessWidget {
  const ScanBookTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Camera preview - Quét QR sách',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Đưa QR Code sách vào khung hình',
                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Tải ảnh lên'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text('Lịch sử quét'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
