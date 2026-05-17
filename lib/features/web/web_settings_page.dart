import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/utils/web_download.dart';
import '../../services/auth_service.dart';
import '../../services/library_data_export_service.dart';
import '../../gen/l10n/app_localizations.dart';
import '../dashboard/library_settings_tab.dart';

/// Panel cố định trên UI để biết “lỗi ở đâu” mà không cần đọc console.
class _WebSettingsDebugPanel extends StatelessWidget {
  final BoxConstraints layoutConstraints;
  final bool providerOk;
  final String? uid;
  final Future<void> Function() onReloadRoleFromFirestore;

  const _WebSettingsDebugPanel({
    required this.layoutConstraints,
    required this.providerOk,
    required this.uid,
    required this.onReloadRoleFromFirestore,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final w = layoutConstraints.maxWidth;
    final h = layoutConstraints.maxHeight;
    final wh =
        '${w.isFinite ? w.toStringAsFixed(0) : "∞"} × ${h.isFinite ? h.toStringAsFixed(0) : "∞"}';
    final text = StringBuffer()
      ..writeln(t.webDebugPanelHeader)
      ..writeln('kIsWeb: $kIsWeb')
      ..writeln('AppUser.role (RAM): ${AppUser.currentRole.name}')
      ..writeln('isStaff: ${AppUser.isStaff}   isAdmin: ${AppUser.isAdmin}')
      ..writeln(
        'Provider AppSettingsController: ${providerOk ? t.webDebugPanelProviderYes : t.webDebugPanelProviderNo}',
      )
      ..writeln('Auth uid: ${uid ?? "null"}')
      ..writeln('Layout maxWidth×maxHeight: $wh')
      ..writeln('')
      ..writeln(t.webDebugPanelRoleMismatchHint);

    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFFB300)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText(
              text.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await onReloadRoleFromFirestore();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(t.reloadRoleSuccess)));
                }
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(t.reloadRoleButton),
            ),
          ],
        ),
      ),
    );
  }
}

class WebSettingsPage extends StatefulWidget {
  const WebSettingsPage({super.key});

  @override
  State<WebSettingsPage> createState() => _WebSettingsPageState();
}

class _WebSettingsPageState extends State<WebSettingsPage> {
  bool _exportBusy = false;

  AppSettingsController? _settingsOrNull(BuildContext context) {
    try {
      return Provider.of<AppSettingsController>(context, listen: true);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickTheme() async {
    final settings = _settingsOrNull(context);
    if (settings == null) return;
    final t = AppLocalizations.of(context)!;
    final chosen = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.settingsTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(t.themeSystem),
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.themeLight),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.themeDark),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.commonClose),
            ),
          ],
        );
      },
    );
    if (chosen != null) await settings.setThemeMode(chosen);
  }

  Future<void> _pickLocale() async {
    final settings = _settingsOrNull(context);
    if (settings == null) return;
    final t = AppLocalizations.of(context)!;
    final chosen = await showDialog<Locale>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.settingsLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: Text(t.languageVietnamese),
                value: const Locale('vi'),
                groupValue: settings.locale,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
              RadioListTile<Locale>(
                title: Text(t.languageEnglish),
                value: const Locale('en'),
                groupValue: settings.locale,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.commonClose),
            ),
          ],
        );
      },
    );
    if (chosen != null) await settings.setLocale(chosen);
  }

  Future<void> _exportJson() async {
    if (!AppUser.isStaff) return;
    final t = AppLocalizations.of(context)!;
    setState(() => _exportBusy = true);
    try {
      final json = await LibraryDataExportService.buildLibraryJsonExport();
      if (kIsWeb) {
        triggerWebDownload(
          'library_export_${DateTime.now().millisecondsSinceEpoch}.json',
          json,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.settingsJsonDownloaded)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.settingsExportFailed('$e'))));
      }
    } finally {
      if (mounted) setState(() => _exportBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid;
    final settings = _settingsOrNull(context);

    if (settings == null) {
      return LayoutBuilder(
        builder: (context, lc) {
          return ColoredBox(
            color: theme.colorScheme.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      t.settingsProviderMissingBody,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _WebSettingsDebugPanel(
                      layoutConstraints: lc,
                      providerOk: false,
                      uid: uid,
                      onReloadRoleFromFirestore: () async {
                        await AuthService.reloadUserRole();
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        if (!maxH.isFinite || maxH <= 0) {
          return ColoredBox(
            color: theme.colorScheme.surface,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return ColoredBox(
          color: theme.colorScheme.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720, maxHeight: maxH),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
                children: [
                  Text(
                    t.webSystemSettingsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.webSystemSettingsSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (kDebugMode) ...[
                    _WebSettingsDebugPanel(
                      layoutConstraints: constraints,
                      providerOk: true,
                      uid: uid,
                      onReloadRoleFromFirestore: () async {
                        await AuthService.reloadUserRole();
                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                  if (uid != null)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child:
                            StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>
                            >(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .snapshots(),
                              builder: (context, snap) {
                                final data = snap.data?.data();
                                final roleStr = (data?['role'] ?? '')
                                    .toString();
                                final roleLabel =
                                    LibrarySettingsTab.roleLabelForUi(
                                      t,
                                      roleStr,
                                    );
                                final email =
                                    (data?['email'] ?? authUser?.email ?? '—')
                                        .toString();
                                final avatarUrl =
                                    (data?['avatarUrl'] ??
                                            authUser?.photoURL ??
                                            '')
                                        .toString()
                                        .trim();
                                return Wrap(
                                  spacing: 18,
                                  runSpacing: 16,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      backgroundImage: avatarUrl.isNotEmpty
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                      child: avatarUrl.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              size: 32,
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            )
                                          : null,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          roleLabel,
                                          style: AppTextStyles.h3.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          email,
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                    OutlinedButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.profile,
                                      ),
                                      child: Text(t.profileButton),
                                    ),
                                  ],
                                );
                              },
                            ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(t.notSignedInTitle),
                      ),
                    ),
                  if (AppUser.isAdmin) ...[
                    const SizedBox(height: 20),
                    SettingsSectionHeader(title: t.webAdminSettingsSection),
                    SettingsGroup(
                      children: [
                        SettingsRow(
                          leadingIcon: Icons.tune_rounded,
                          iconBgColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          title: t.manageLibraryConfig,
                          trailingIcon: Icons.chevron_right,
                          onTap: () => AppRoutes.pushRoot(
                            context,
                            AppRoutes.libraryBusinessSettings,
                          ),
                        ),
                        SettingsRow(
                          leadingIcon: Icons.history_edu_outlined,
                          iconBgColor: AppColors.secondary.withValues(
                            alpha: 0.12,
                          ),
                          title: t.manageAuditLog,
                          trailingIcon: Icons.chevron_right,
                          onTap: () =>
                              AppRoutes.pushRoot(context, AppRoutes.auditLog),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  SettingsSectionHeader(title: t.settingsLanguageAppearance),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        leadingIcon: Icons.translate,
                        iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                        title: t.settingsLanguage,
                        trailingIcon: Icons.chevron_right,
                        trailingText: settings.locale.languageCode == 'en'
                            ? t.languageEnglish
                            : t.languageVietnamese,
                        onTap: _pickLocale,
                      ),
                      SettingsRow(
                        leadingIcon: Icons.dark_mode,
                        iconBgColor: const Color(
                          0xFF7C3AED,
                        ).withValues(alpha: 0.12),
                        title: t.settingsTheme,
                        trailingIcon: Icons.chevron_right,
                        trailingText: switch (settings.themeMode) {
                          ThemeMode.system => t.themeSystem,
                          ThemeMode.light => t.themeLight,
                          ThemeMode.dark => t.themeDark,
                        },
                        onTap: _pickTheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SettingsSectionHeader(title: t.settingsNotifications),
                  SettingsGroup(
                    children: [
                      if (uid != null)
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snap) {
                            final data = snap.data?.data();
                            final raw = data?['notifyBorrowReminders'];
                            final on = raw is! bool || raw;
                            return SettingsToggle(
                              leadingIcon: Icons.notifications_outlined,
                              iconBgColor: AppColors.error.withValues(
                                alpha: 0.12,
                              ),
                              title: t.settingsBorrowReturnNotificationsTitle,
                              subtitle: t.settingsBorrowReturnNotificationsBody,
                              value: on,
                              onChanged: (v) async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .set({
                                      'notifyBorrowReminders': v,
                                    }, SetOptions(merge: true));
                              },
                            );
                          },
                        )
                      else
                        SettingsToggle(
                          leadingIcon: Icons.notifications_outlined,
                          iconBgColor: AppColors.error.withValues(alpha: 0.12),
                          title: t.settingsNotifications,
                          subtitle: t.signInToConfigure,
                          value: false,
                          onChanged: null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SettingsSectionHeader(title: t.settingsLibraryData),
                  SettingsGroup(
                    children: [
                      SettingsButtonRow(
                        leadingIcon: Icons.cloud_download_outlined,
                        leadingColor: AppColors.primary,
                        title: t.settingsExportJsonTitle,
                        onTap: _exportBusy || !AppUser.isStaff
                            ? () {}
                            : () async {
                                await _exportJson();
                              },
                      ),
                      if (_exportBusy)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await AuthService.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      },
                      child: Text(
                        t.settingsSignOutAction,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
