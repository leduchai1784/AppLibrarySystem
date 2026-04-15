import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/feature_flags_service.dart';
import '../../services/library_config_service.dart';

/// Cấu hình hệ thống: bật/tắt các chức năng trong app (feature flags).
///
/// Lưu tại: `library_settings/config.features`.
class SystemFeatureSettingsScreen extends StatefulWidget {
  const SystemFeatureSettingsScreen({super.key});

  @override
  State<SystemFeatureSettingsScreen> createState() => _SystemFeatureSettingsScreenState();
}

class _SystemFeatureSettingsScreenState extends State<SystemFeatureSettingsScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!AppUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(t.systemFeaturesTitle)),
        body: Center(child: Text(t.adminOnlyLibraryConfig)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.systemFeaturesTitle),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: LibraryConfigService.configRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data?.data() ?? {};
          final raw = data['features'];
          final flags = FeatureFlagsService.defaults();
          if (raw is Map) {
            for (final e in raw.entries) {
              final k = e.key.toString();
              final v = e.value;
              if (v is bool && flags.containsKey(k)) flags[k] = v;
            }
          }

          Future<void> toggle(String key, bool value) async {
            final messenger = ScaffoldMessenger.of(context);
            setState(() => _saving = true);
            try {
              final next = Map<String, bool>.from(flags)..[key] = value;
              await FeatureFlagsService.saveFlags(next);
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text(t.systemFeaturesSaved)),
                );
              }
            } catch (e) {
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text(t.libraryConfigSaveError('$e'))),
                );
              }
            } finally {
              if (mounted) setState(() => _saving = false);
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                t.systemFeaturesSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: t.systemFeaturesCoreSection,
                children: [
                  _SwitchTile(
                    title: t.systemFeaturesScan,
                    subtitle: t.systemFeaturesScanHint,
                    value: flags[FeatureFlagsService.scanEnabled] ?? true,
                    onChanged: _saving ? null : (v) => toggle(FeatureFlagsService.scanEnabled, v),
                  ),
                  _SwitchTile(
                    title: t.systemFeaturesBorrowReturn,
                    subtitle: t.systemFeaturesBorrowReturnHint,
                    value: flags[FeatureFlagsService.borrowReturnEnabled] ?? true,
                    onChanged:
                        _saving ? null : (v) => toggle(FeatureFlagsService.borrowReturnEnabled, v),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: t.systemFeaturesAiSection,
                children: [
                  _SwitchTile(
                    title: t.systemFeaturesAiRecommendations,
                    subtitle: t.systemFeaturesAiRecommendationsHint,
                    value: flags[FeatureFlagsService.aiRecommendationsEnabled] ?? true,
                    onChanged: _saving
                        ? null
                        : (v) => toggle(FeatureFlagsService.aiRecommendationsEnabled, v),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: t.systemFeaturesReportsSection,
                children: [
                  _SwitchTile(
                    title: t.systemFeaturesStatistics,
                    subtitle: t.systemFeaturesStatisticsHint,
                    value: flags[FeatureFlagsService.statisticsEnabled] ?? true,
                    onChanged: _saving
                        ? null
                        : (v) => toggle(FeatureFlagsService.statisticsEnabled, v),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}

