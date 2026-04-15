import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';

/// Trang "Cấu hình hệ thống" cho web: gom các cấu hình quan trọng của Admin/Staff.
///
/// Lý do tồn tại:
/// - Web shell có mục sidebar riêng cho "Cấu hình hệ thống"
/// - Tránh nhầm với tab "Cài đặt" (tùy chọn app) vốn chỉ là 1 phần.
class WebSystemConfigPage extends StatelessWidget {
  const WebSystemConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      children: [
        Text(
          t.webSectionSystemConfig,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          t.systemFeaturesSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 16),
        _LinkCard(
          title: t.systemFeaturesTitle,
          subtitle: t.systemFeaturesSubtitle,
          icon: Icons.toggle_on_rounded,
          onTap: () => AppRoutes.pushRoot(context, AppRoutes.systemFeatures),
        ),
        const SizedBox(height: 10),
        _LinkCard(
          title: t.manageLibraryConfig,
          subtitle: t.libraryBusinessSettingsSubtitle,
          icon: Icons.tune_rounded,
          onTap: () => AppRoutes.pushRoot(context, AppRoutes.libraryBusinessSettings),
        ),
        const SizedBox(height: 10),
        _LinkCard(
          title: t.settingsTitle,
          subtitle: AppUser.isStaff ? t.signInToConfigure : t.needSignIn,
          icon: Icons.settings_outlined,
          onTap: () => AppRoutes.pushRoot(context, AppRoutes.settings),
        ),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, height: 1.3),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
  }
}

