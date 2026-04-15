import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// Trang chủ dashboard web — không dùng lại layout mobile AdminHomeTab.
class WebStaffHomePage extends StatelessWidget {
  const WebStaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final roleLabel = AppUser.isAdmin ? t.roleAdmin : t.roleManager;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.webHello,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roleLabel,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.webAdminOverviewSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 28),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snapshot) {
              var totalQty = 0;
              var available = 0;
              var titles = 0;
              if (snapshot.hasData) {
                titles = snapshot.data!.docs.length;
                for (final d in snapshot.data!.docs) {
                  final data = d.data();
                  final q = (data['quantity'] ?? 0) as int;
                  final a = (data['availableQuantity'] ?? data['available'] ?? q) as int;
                  totalQty += q;
                  available += a;
                }
              }
              final borrowed = totalQty - available;
              return LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final cross = w >= 1100 ? 4 : (w >= 700 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: cross,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: cross >= 4 ? 1.85 : 1.4,
                    children: [
                      _MetricTile(
                        label: t.webMetricTitles,
                        value: '$titles',
                        sub: t.webMetricTitlesSub,
                        icon: Icons.auto_stories_outlined,
                        color: const Color(0xFF2563EB),
                      ),
                      _MetricTile(
                        label: t.webMetricTotalCopies,
                        value: '$totalQty',
                        sub: t.webMetricTotalCopiesSub,
                        icon: Icons.numbers,
                        color: const Color(0xFF059669),
                      ),
                      _MetricTile(
                        label: t.webMetricAvailable,
                        value: '$available',
                        sub: t.webMetricAvailableSub,
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFFD97706),
                      ),
                      _MetricTile(
                        label: t.webMetricBorrowed,
                        value: '$borrowed',
                        sub: t.webMetricBorrowedSub,
                        icon: Icons.swap_horiz,
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 36),
          Text(t.quickActions, style: AppTextStyles.h3),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionChip(
                label: t.quickCreateBorrow,
                icon: Icons.add_circle_outline,
                onTap: () => AppRoutes.openBorrowCreate(context),
              ),
              _ActionChip(
                label: t.quickReturn,
                icon: Icons.keyboard_return,
                onTap: () => AppRoutes.openReturnBook(context),
              ),
              _ActionChip(
                label: t.quickCurrentBorrows,
                icon: Icons.bookmark_outline,
                onTap: () => AppRoutes.pushRoot(context, AppRoutes.currentBorrows),
              ),
              _ActionChip(
                label: t.quickHistory,
                icon: Icons.history,
                onTap: () => AppRoutes.pushRoot(context, AppRoutes.borrowHistory),
              ),
              _ActionChip(
                label: t.webQuickAddBook,
                icon: Icons.library_add_outlined,
                onTap: () => AppRoutes.pushRoot(context, AppRoutes.addBook),
              ),
              _ActionChip(
                label: t.webQuickStats,
                icon: Icons.analytics_outlined,
                onTap: () => AppRoutes.pushRoot(context, AppRoutes.statistics),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
