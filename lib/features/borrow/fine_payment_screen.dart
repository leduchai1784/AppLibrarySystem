import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/guards/role_guard.dart';
import '../../gen/l10n/app_localizations.dart';

/// Nhân sự ghi nhận thu tiền phạt (phiếu `late`, `fineAmount` > 0, chưa `finePaid`).
class FinePaymentScreen extends StatefulWidget {
  const FinePaymentScreen({super.key});

  @override
  State<FinePaymentScreen> createState() => _FinePaymentScreenState();
}

String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString();
  return '$d/$m/$y';
}

class _FinePaymentScreenState extends State<FinePaymentScreen> {
  String? _busyRecordId;

  static Query<Map<String, dynamic>> _unpaidLateQuery() {
    return FirebaseFirestore.instance
        .collection('borrow_records')
        .where('status', isEqualTo: 'late')
        .orderBy('returnDate', descending: true)
        .limit(200);
  }

  static bool _isUnpaidFine(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final fine = (m['fineAmount'] as num?)?.toInt() ?? 0;
    if (fine <= 0) return false;
    if (m['finePaid'] == true) return false;
    return true;
  }

  Future<void> _recordPayment({
    required String recordId,
    required String borrowerUserId,
    required int amount,
    required String methodKey,
    required String methodLabel,
  }) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.finePaymentConfirmTitle),
          content: Text(
            t.finePaymentConfirmBody('$amount', recordId, methodLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.commonDone),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _busyRecordId = recordId);
    try {
      final batch = FirebaseFirestore.instance.batch();
      final payRef = FirebaseFirestore.instance.collection('payments').doc();
      final borrowRef = FirebaseFirestore.instance
          .collection('borrow_records')
          .doc(recordId);
      batch.set(payRef, {
        'userId': borrowerUserId,
        'borrowRecordId': recordId,
        'amount': amount,
        'method': methodKey,
        'createdAt': FieldValue.serverTimestamp(),
        'processedBy': uid,
      });
      batch.update(borrowRef, {
        'finePaid': true,
        'finePaidAt': FieldValue.serverTimestamp(),
        'finePaymentId': payRef.id,
      });
      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.finePaymentRecorded)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.genericErrorWithMessage('$e'))));
    } finally {
      if (mounted) setState(() => _busyRecordId = null);
    }
  }

  Future<void> _openMethodPickerAndPay({
    required String recordId,
    required String borrowerUserId,
    required int amount,
  }) async {
    final t = AppLocalizations.of(context)!;
    final method = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(t.paymentMethodTitle, style: AppTextStyles.h3),
              ),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(t.cashAtLibrary),
                onTap: () => Navigator.pop(ctx, 'cash'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: Text(t.bankTransfer),
                onTap: () => Navigator.pop(ctx, 'transfer'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (method == null || !mounted) return;
    final methodLabel = method == 'transfer' ? t.bankTransfer : t.cashAtLibrary;
    await _recordPayment(
      recordId: recordId,
      borrowerUserId: borrowerUserId,
      amount: amount,
      methodKey: method,
      methodLabel: methodLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!RoleGuard.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.finePaymentTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.finePaymentStaffOnly,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.finePaymentTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _unpaidLateQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.genericErrorWithMessage('${snapshot.error}')),
              ),
            );
          }
          final unpaid = (snapshot.data?.docs ?? [])
              .where(_isUnpaidFine)
              .toList();
          if (unpaid.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t.finePaymentEmptyList,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: unpaid.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final doc = unpaid[i];
              final m = doc.data();
              final title = (m['bookTitleSnapshot'] ?? '').toString().trim();
              final userId = (m['userId'] ?? '').toString();
              final fine = (m['fineAmount'] as num?)?.toInt() ?? 0;
              final ret = (m['returnDate'] as Timestamp?)?.toDate();
              final busy = _busyRecordId == doc.id;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isNotEmpty ? title : doc.id,
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${t.ticketIdLabel}: ${doc.id}',
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  'UID: $userId',
                                  style: AppTextStyles.caption,
                                ),
                                if (ret != null)
                                  Text(
                                    '${t.returnDateLabelShort}: ${_formatDate(ret)}',
                                    style: AppTextStyles.caption,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              t.finePrefix('$fine'),
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: busy || userId.isEmpty || fine <= 0
                              ? null
                              : () => _openMethodPickerAndPay(
                                  recordId: doc.id,
                                  borrowerUserId: userId,
                                  amount: fine,
                                ),
                          child: busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(t.finePaymentMarkPaid),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
