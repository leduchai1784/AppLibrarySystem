import 'package:flutter/material.dart';

/// Màn hình tạo phiếu mượn sách - UI only
class BorrowCreateScreen extends StatelessWidget {
  const BorrowCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo phiếu mượn sách'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quét QR Code sách', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Chạm để quét QR Code sách', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Hoặc nhập mã sách', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(hintText: 'Mã sách / ISBN'),
            ),
            const SizedBox(height: 12),
            Text('Sinh viên mượn', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              decoration: const InputDecoration(
                hintText: 'MSSV hoặc email sinh viên',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Text('Ngày mượn', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: '28/02/2026',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),
            Text('Ngày trả dự kiến', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: '14/03/2026',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('TẠO PHIẾU MƯỢN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
