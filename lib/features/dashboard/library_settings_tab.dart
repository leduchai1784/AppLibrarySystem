import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/utils/web_download.dart';
import '../../services/auth_service.dart';
import '../../services/library_data_export_service.dart';
import '../../services/push_notification_service.dart';
import '../../gen/l10n/app_localizations.dart';

/// Tab Cài đặt - giao diện hoàn chỉnh cho Admin và Sinh viên
class LibrarySettingsTab extends StatelessWidget {
  const LibrarySettingsTab({super.key});

  static String _roleLabel(AppLocalizations t, String? roleStr) {
    switch ((roleStr ?? '').trim().toLowerCase()) {
      case 'admin':
        return t.roleAdmin;
      case 'manager':
        return t.roleManager;
      default:
        return t.roleStudent;
    }
  }

  /// Dùng từ widget con trong cùng file (ví dụ panel web).
  static String roleLabelForUi(AppLocalizations t, String? roleStr) => _roleLabel(t, roleStr);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _LibrarySettingsWebPanel();
    }
    return const _LibrarySettingsMobilePanel();
  }

  /// Header hồ sơ dùng chung cho panel mobile.
  static Widget buildMobileProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid;

    if (uid == null) {
      return Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(Icons.person_rounded, size: 34, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.notSignedInTitle,
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
        ),
        padding: const EdgeInsets.all(14),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data();
            final roleStr = (data?['role'] ?? '').toString();
            final label = _roleLabel(t, roleStr);
            final email = (data?['email'] ?? authUser?.email ?? '').toString();
            final avatarUrl = (data?['avatarUrl'] ?? authUser?.photoURL ?? '').toString().trim();
            final studentCode = (data?['studentCode'] ?? '').toString().trim();
            final isStudent = roleStr.trim().toLowerCase() == 'student';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isNotEmpty
                            ? null
                            : Icon(Icons.person_rounded, size: 34, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email.isEmpty ? '—' : email,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: Text(t.profileButton, style: const TextStyle(fontSize: 13.5)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.55)),
                          ),
                        ),
                      ),
                    ),
                    if (isStudent) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.myQr),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 17),
                            label: Text(t.myQrButton, style: const TextStyle(fontSize: 13.5)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.55)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isStudent && studentCode.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    t.studentCodeLabel(studentCode),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LibrarySettingsMobilePanel extends StatefulWidget {
  const _LibrarySettingsMobilePanel();

  @override
  State<_LibrarySettingsMobilePanel> createState() => _LibrarySettingsMobilePanelState();
}

class _LibrarySettingsMobilePanelState extends State<_LibrarySettingsMobilePanel> {
  bool _backupBusy = false;
  Future<void> _pickTheme(AppSettingsController settings) async {
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonClose)),
          ],
        );
      },
    );
    if (chosen != null) await settings.setThemeMode(chosen);
  }

  Future<void> _pickLocale(AppSettingsController settings) async {
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonClose)),
          ],
        );
      },
    );
    if (chosen != null) await settings.setLocale(chosen);
  }

  Future<void> _pickQrColor(AppSettingsController settings) async {
    final t = AppLocalizations.of(context)!;
    final presets = <Color>[
      const Color(AppSettingsController.defaultQrColorArgb),
      const Color(0xFF7C3AED),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF0F172A),
    ];
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.defaultQrColorTitle),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets
                .map(
                  (c) => InkWell(
                    onTap: () => Navigator.pop(ctx, c),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: c,
                      child: settings.qrDefaultColor.toARGB32() == c.toARGB32()
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonClose)),
          ],
        );
      },
    );
    if (picked != null) await settings.setQrDefaultColor(picked);
  }

  Future<void> _pickQrSize(AppSettingsController settings) async {
    final t = AppLocalizations.of(context)!;
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.defaultQrSizeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: Text(t.qrSizeSmall200),
                value: 0,
                groupValue: settings.qrSizeLevel,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
              RadioListTile<int>(
                title: Text(t.qrSizeMedium256),
                value: 1,
                groupValue: settings.qrSizeLevel,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
              RadioListTile<int>(
                title: Text(t.qrSizeLarge300),
                value: 2,
                groupValue: settings.qrSizeLevel,
                onChanged: (v) => Navigator.pop(ctx, v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonClose)),
          ],
        );
      },
    );
    if (chosen != null) await settings.setQrSizeLevel(chosen);
  }

  Future<void> _runBackup(AppSettingsController settings) async {
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.needSignIn)),
      );
      return;
    }
    setState(() => _backupBusy = true);
    try {
      final json = AppUser.isStaff
          ? await LibraryDataExportService.buildLibraryJsonExport()
          : await LibraryDataExportService.buildStudentBorrowsJsonExport(uid);
      final dir = await getTemporaryDirectory();
      final name = AppUser.isStaff ? 'library_backup.json' : 'my_borrows_backup.json';
      final f = File('${dir.path}/$name');
      await f.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(f.path)],
          text: t.settingsBackup,
        ),
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.genericErrorWithMessage('$e'))));
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _confirmClearLocal(AppSettingsController settings) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.clearLocalDataTitle),
          content: Text(
            t.clearLocalDataBody,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.commonCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.clearLocalDataConfirm),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    await settings.clearAllAppPreferences();
    await AuthService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _loadBiometricCapability() async {
    // No-op: sinh trắc học đã bỏ theo yêu cầu.
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBiometricCapability());
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    final t = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 20 + bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LibrarySettingsTab.buildMobileProfileHeader(context),
          const SizedBox(height: 12),
          _SectionHeader(title: t.settingsAppPreferences),
          _SettingsGroup(
            children: [
              _SettingsRow(
                leadingIcon: Icons.translate,
                iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                title: t.settingsLanguage,
                trailingIcon: Icons.chevron_right,
                trailingText: settings.locale.languageCode == 'en' ? t.languageEnglish : t.languageVietnamese,
                onTap: () => _pickLocale(settings),
              ),
              _SettingsRow(
                leadingIcon: Icons.dark_mode,
                iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                title: t.settingsTheme,
                trailingIcon: Icons.chevron_right,
                trailingText: switch (settings.themeMode) {
                  ThemeMode.system => t.themeSystem,
                  ThemeMode.light => t.themeLight,
                  ThemeMode.dark => t.themeDark,
                },
                onTap: () => _pickTheme(settings),
              ),
              if (uid != null)
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                  builder: (context, snap) {
                    final data = snap.data?.data();
                    final raw = data?['notifyBorrowReminders'];
                    final on = raw is! bool || raw;
                    return _SettingsToggle(
                      leadingIcon: Icons.notifications,
                      iconBgColor: AppColors.error.withValues(alpha: 0.12),
                      title: t.settingsInAppNotifications,
                      subtitle: t.settingsBorrowReturnNotifsHint,
                      value: on,
                      onChanged: (v) async {
                        await FirebaseFirestore.instance.collection('users').doc(uid).set(
                          {'notifyBorrowReminders': v},
                          SetOptions(merge: true),
                        );
                      },
                    );
                  },
                )
              else
                _SettingsToggle(
                  leadingIcon: Icons.notifications,
                  iconBgColor: AppColors.error.withValues(alpha: 0.12),
                  title: t.settingsInAppNotifications,
                  subtitle: t.signInToConfigure,
                  value: false,
                  onChanged: null,
                ),
              _SettingsToggle(
                leadingIcon: Icons.send,
                iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                title: t.settingsPushNotifications,
                subtitle: t.settingsPushNotifsHint,
                value: settings.pushNotificationsEnabled,
                onChanged: (v) async {
                  await settings.setPushNotificationsEnabled(v);
                  await PushNotificationService.onPushSettingChanged(enabled: v, uid: uid);
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SectionHeader(title: t.settingsDefaultQrStyle),
          _SettingsGroup(
            children: [
              _SettingsRow(
                leadingIcon: Icons.palette,
                iconBgColor: AppColors.secondary.withValues(alpha: 0.14),
                title: t.settingsDefaultColor,
                trailingIcon: Icons.chevron_right,
                trailingDotColor: settings.qrDefaultColor,
                onTap: () => _pickQrColor(settings),
              ),
              _SettingsRow(
                leadingIcon: Icons.aspect_ratio,
                iconBgColor: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                title: t.settingsDefaultSize,
                trailingIcon: Icons.chevron_right,
                trailingText: switch (settings.qrSizeLevel) {
                  0 => t.qrSizeSmall200,
                  1 => t.qrSizeMedium256,
                  _ => t.qrSizeLarge300,
                },
                onTap: () => _pickQrSize(settings),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SectionHeader(title: t.settingsCameraScanning),
          _SettingsGroup(
            children: [
              _SettingsToggle(
                leadingIcon: Icons.center_focus_strong,
                iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
                title: t.settingsScannerAutofocus,
                subtitle: t.settingsAutofocusHint,
                value: settings.scannerAutofocusEnabled,
                onChanged: (v) => settings.setScannerAutofocus(v),
              ),
              _SettingsToggle(
                leadingIcon: Icons.volume_up,
                iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
                title: t.settingsScannerBeep,
                value: settings.scannerSoundEnabled,
                onChanged: (v) => settings.setScannerSound(v),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _SectionHeader(title: 'Thông tin ứng dụng'),
          _SettingsGroup(
            children: const [
              _AppVersionRow(),
            ],
          ),
          const SizedBox(height: 10),
          _SectionHeader(title: t.settingsData),
          _SettingsGroup(
            children: [
              if (_backupBusy)
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              _SettingsButtonRow(
                leadingIcon: Icons.cloud_upload,
                leadingColor: AppColors.primary,
                title: AppUser.isStaff ? t.settingsBackupLibraryJson : t.settingsBackupMyBorrows,
                onTap: _backupBusy ? () {} : () => _runBackup(settings),
              ),
              _SettingsButtonRow(
                leadingIcon: Icons.delete_forever,
                leadingColor: AppColors.error,
                title: t.settingsClearLocalData,
                onTap: () => _confirmClearLocal(settings),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              child: Text(t.settingsSignOutAction, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final w = layoutConstraints.maxWidth;
    final h = layoutConstraints.maxHeight;
    final wh = '${w.isFinite ? w.toStringAsFixed(0) : "∞"} × ${h.isFinite ? h.toStringAsFixed(0) : "∞"}';
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
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await onReloadRoleFromFirestore();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.reloadRoleSuccess)),
                  );
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

/// Giao diện cài đặt tối ưu cho web: khối rộng vừa phải, bỏ nhóm chỉ dành cho mobile.
class _LibrarySettingsWebPanel extends StatefulWidget {
  const _LibrarySettingsWebPanel();

  @override
  State<_LibrarySettingsWebPanel> createState() => _LibrarySettingsWebPanelState();
}

class _LibrarySettingsWebPanelState extends State<_LibrarySettingsWebPanel> {
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonClose)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonClose)),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.settingsJsonDownloaded)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settingsExportFailed('$e'))),
        );
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
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
              const SizedBox(height: 8),
              Text(
                t.webSystemSettingsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, height: 1.35),
              ),
              const SizedBox(height: 16),
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
              if (uid != null)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.45)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                      builder: (context, snap) {
                        final data = snap.data?.data();
                        final roleStr = (data?['role'] ?? '').toString();
                        final roleLabel = LibrarySettingsTab.roleLabelForUi(t, roleStr);
                        final email = (data?['email'] ?? authUser?.email ?? '—').toString();
                        final avatarUrl = (data?['avatarUrl'] ?? authUser?.photoURL ?? '').toString().trim();
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl.isEmpty
                                  ? Icon(Icons.person, size: 32, color: theme.colorScheme.onPrimaryContainer)
                                  : null,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(roleLabel, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  SelectableText(email, style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
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
                _SectionHeader(title: t.webAdminSettingsSection),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      leadingIcon: Icons.tune_rounded,
                      iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                      title: t.manageLibraryConfig,
                      trailingIcon: Icons.chevron_right,
                      onTap: () => AppRoutes.pushRoot(context, AppRoutes.libraryBusinessSettings),
                    ),
                    _SettingsRow(
                      leadingIcon: Icons.history_edu_outlined,
                      iconBgColor: AppColors.secondary.withValues(alpha: 0.12),
                      title: t.manageAuditLog,
                      trailingIcon: Icons.chevron_right,
                      onTap: () => AppRoutes.pushRoot(context, AppRoutes.auditLog),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              _SectionHeader(title: t.settingsLanguageAppearance),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    leadingIcon: Icons.translate,
                    iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                    title: t.settingsLanguage,
                    trailingIcon: Icons.chevron_right,
                    trailingText: settings.locale.languageCode == 'en' ? t.languageEnglish : t.languageVietnamese,
                    onTap: _pickLocale,
                  ),
                  _SettingsRow(
                    leadingIcon: Icons.dark_mode,
                    iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
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
              _SectionHeader(title: t.settingsNotifications),
              _SettingsGroup(
                children: [
                  if (uid != null)
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                      builder: (context, snap) {
                        final data = snap.data?.data();
                        final raw = data?['notifyBorrowReminders'];
                        final on = raw is! bool || raw;
                        return _SettingsToggle(
                          leadingIcon: Icons.notifications_outlined,
                          iconBgColor: AppColors.error.withValues(alpha: 0.12),
                          title: t.settingsBorrowReturnNotificationsTitle,
                          subtitle: t.settingsBorrowReturnNotificationsBody,
                          value: on,
                          onChanged: (v) async {
                            await FirebaseFirestore.instance.collection('users').doc(uid).set(
                              {'notifyBorrowReminders': v},
                              SetOptions(merge: true),
                            );
                          },
                        );
                      },
                    )
                  else
                    _SettingsToggle(
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
              _SectionHeader(title: t.settingsLibraryData),
              _SettingsGroup(
                children: [
                  _SettingsButtonRow(
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
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.phone_android, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.settingsMobileConfigHint,
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  child: Text(t.settingsSignOutAction, style: const TextStyle(fontWeight: FontWeight.w800)),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          letterSpacing: 0.2,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      tiles.add(children[i]);
      if (i < children.length - 1) {
        tiles.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 50,
            endIndent: 10,
            color: theme.dividerColor.withValues(alpha: 0.28),
          ),
        );
      }
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: tiles),
      ),
    );
  }
}

class _AppVersionRow extends StatelessWidget {
  const _AppVersionRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        final version = info?.version ?? '—';
        final build = info?.buildNumber ?? '—';
        return ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
          ),
          title: const Text('Phiên bản ứng dụng'),
          subtitle: Text('Version $version ($build)'),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        );
      },
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData leadingIcon;
  final Color iconBgColor;
  final String title;
  final IconData? trailingIcon;
  final String? trailingText;
  final Color? trailingDotColor;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.leadingIcon,
    required this.iconBgColor,
    required this.title,
    this.trailingIcon,
    this.trailingText,
    this.trailingDotColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = trailingText != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  trailingText!,
                  style: AppTextStyles.caption.copyWith(fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            ],
          )
        : trailingDotColor != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: trailingDotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                    ),
                  ),
                  if (trailingIcon != null) const SizedBox(width: 6),
                  if (trailingIcon != null)
                    Icon(trailingIcon, size: 20, color: theme.colorScheme.onSurfaceVariant),
                ],
              )
            : trailingIcon != null
                ? Icon(trailingIcon, size: 20, color: theme.colorScheme.onSurfaceVariant)
                : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(leadingIcon, size: 18, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14.5, height: 1.2),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatefulWidget {
  final IconData leadingIcon;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsToggle({
    required this.leadingIcon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        crossAxisAlignment: widget.subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.iconBgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(widget.leadingIcon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14.5, height: 1.2),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12.5,
                      height: 1.25,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Switch.adaptive(
            value: widget.value,
            onChanged: widget.onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _SettingsButtonRow extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingColor;
  final String title;
  final VoidCallback onTap;

  const _SettingsButtonRow({
    required this.leadingIcon,
    required this.leadingColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(leadingIcon, color: leadingColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: leadingColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  height: 1.2,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55)),
          ],
        ),
      ),
    );
  }
}
