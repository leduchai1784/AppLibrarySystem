import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình thanh toán phạt trả trễ - UI only
class FineScreen extends StatelessWidget {
  const FineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // UI demo data only
    final totalFine = t.fineDemoTotalAmount;
    final breakdown = t.fineDemoTotalExplanation;
    final itemFine = t.fineDemoLineAmount;
    final itemLate = t.fineDemoLineLateLabel;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.finePaymentTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.error.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.totalFineLabel, style: AppTextStyles.h2),
                        Text(totalFine, style: AppTextStyles.h1.copyWith(color: AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(breakdown, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(t.fineDetailsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...List.generate(2, (i) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.menu_book, color: AppColors.primary),
                  title: Text('${t.bookLabel} ${i + 1}', style: AppTextStyles.body),
                  subtitle: Text(itemLate, style: AppTextStyles.caption),
                  trailing: Text(itemFine, style: AppTextStyles.body.copyWith(color: AppColors.error)),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(t.paymentMethodTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: Text(t.cashAtLibrary),
              value: 'cash',
              groupValue: 'cash',
              onChanged: (_) {},
            ),
            RadioListTile<String>(
              title: Text(t.bankTransfer),
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
                child: Text(t.payAmountButton(t.fineDemoTotalAmount)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
