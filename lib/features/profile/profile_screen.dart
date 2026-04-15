import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

InputDecoration _profileEditFieldDecoration(ThemeData theme, String label, IconData icon) {
  return InputDecoration(
    isDense: true,
    labelText: label,
    labelStyle: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurfaceVariant),
    prefixIcon: Icon(icon, size: 20),
    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 40),
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.85), width: 1.4),
    ),
  );
}

/// Form chỉnh hồ sơ trong bottom sheet — controller [dispose] cùng [State] của route,
/// tránh dispose sớm trong `finally` sau [showModalBottomSheet] (gây lỗi `_dependents.isEmpty`).
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.uid,
    required this.roleStr,
    required this.fullName,
    required this.phone,
    required this.studentCode,
    required this.address,
    required this.email,
    required this.snackbarContext,
  });

  final String uid;
  final String roleStr;
  final String fullName;
  final String phone;
  final String studentCode;
  final String address;
  final String email;
  /// [BuildContext] của màn [ProfileScreen] (còn mounted sau khi sheet đóng) để hiện SnackBar.
  final BuildContext snackbarContext;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.fullName);
    _phoneCtrl = TextEditingController(text: widget.phone);
    _codeCtrl = TextEditingController(text: widget.studentCode);
    _addressCtrl = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final t = AppLocalizations.of(context)!;
    final newName = _nameCtrl.text.trim();
    final newPhone = _phoneCtrl.text.trim();
    final newCode = _codeCtrl.text.trim();
    final newAddress = _addressCtrl.text.trim();
    final isStudent = widget.roleStr.toLowerCase() == 'student';

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.pleaseEnterFullName)),
      );
      return;
    }

    final ref = FirebaseFirestore.instance.collection('users').doc(widget.uid);
    final payload = <String, dynamic>{
      'fullName': newName,
      'phone': newPhone,
      'address': newAddress,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isStudent) payload['studentCode'] = newCode;

    try {
      final existing = await ref.get();
      if (!existing.exists) {
        await ref.set({
          ...payload,
          'uid': widget.uid,
          'email': widget.email.trim(),
          'role': 'student',
          'avatarUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'totalBorrowed': 0,
          if (!payload.containsKey('studentCode')) 'studentCode': '',
        });
      } else {
        await ref.set(payload, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      final parent = widget.snackbarContext;
      if (parent.mounted) {
        ScaffoldMessenger.of(parent).showSnackBar(
          SnackBar(content: Text(t.profileUpdated)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.profileUpdateFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isStudent = widget.roleStr.toLowerCase() == 'student';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.profileEdit,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15),
              decoration: _profileEditFieldDecoration(theme, t.profileFullNameLabel, Icons.badge_outlined),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15),
              decoration: _profileEditFieldDecoration(theme, t.profilePhoneLabel, Icons.phone_outlined),
            ),
            if (isStudent) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _codeCtrl,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontSize: 15),
                decoration: _profileEditFieldDecoration(theme, t.profileStudentCodeLabel, Icons.badge_outlined),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 15),
              decoration: _profileEditFieldDecoration(theme, t.profileAddressLabel, Icons.location_on_outlined),
            ),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: _profileEditFieldDecoration(theme, t.profileEmailReadonlyLabel, Icons.email_outlined),
              child: Text(
                widget.email,
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _onSave,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: Text(t.commonSave),
            ),
            TextButton(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.commonCancel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thông tin cá nhân — đồng bộ Firestore `users/{uid}` (realtime).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static Future<void> _openEditProfileSheet(
    BuildContext context, {
    required String uid,
    required String roleStr,
    required String fullName,
    required String phone,
    required String studentCode,
    required String address,
    required String email,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _EditProfileSheet(
        uid: uid,
        roleStr: roleStr,
        fullName: fullName,
        phone: phone,
        studentCode: studentCode,
        address: address,
        email: email,
        snackbarContext: context,
      ),
    );
  }

  static String _roleLabelLocalized(AppLocalizations t, String? r) {
    return switch ((r ?? 'student').toLowerCase()) {
      'admin' => t.roleAdmin,
      'manager' => t.roleManager,
      _ => t.roleStudent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.profileTitle)),
        body: Center(child: Text(t.profileNotSignedIn)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: t.profileEdit,
            onPressed: () async {
              final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              final data = snap.data() ?? {};
              final roleStr = (data['role'] ?? 'student').toString();
              final fullName = (data['fullName'] ?? authUser?.displayName ?? '').toString().trim();
              final phone = (data['phone'] ?? authUser?.phoneNumber ?? '').toString().trim();
              final studentCode = (data['studentCode'] ?? '').toString().trim();
              final address = (data['address'] ?? '').toString().trim();
              final email = (data['email'] ?? authUser?.email ?? '').toString();
              if (!context.mounted) return;
              await _openEditProfileSheet(
                context,
                uid: uid,
                roleStr: roleStr,
                fullName: fullName,
                phone: phone,
                studentCode: studentCode,
                address: address,
                email: email,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(t.profileLoadError('${snap.error}')));
          }
          final data = snap.data?.data();
          final fullName = (data?['fullName'] ?? authUser?.displayName ?? '').toString().trim();
          final email = (data?['email'] ?? authUser?.email ?? '').toString();
          final studentCode = (data?['studentCode'] ?? '').toString().trim();
          final phone = (data?['phone'] ?? authUser?.phoneNumber ?? '').toString().trim();
          final address = (data?['address'] ?? '').toString().trim();
          final avatarUrl = (data?['avatarUrl'] ?? authUser?.photoURL ?? '').toString().trim();
          final roleStr = data?['role'] as String?;
          final roleLabel = _roleLabelLocalized(t, roleStr);
          final isStudent = (roleStr ?? 'student').toLowerCase() == 'student';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isNotEmpty
                              ? null
                              : const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          fullName.isEmpty ? t.profileMissingName : fullName,
                          style: AppTextStyles.h2.copyWith(fontSize: 19, height: 1.2),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: AppTextStyles.caption.copyWith(fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            roleLabel,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileDetailCard(
                  children: [
                    if (isStudent)
                      _ProfileInfoRow(
                        icon: Icons.badge_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primary.withValues(alpha: 0.1),
                        label: t.profileStudentCodeLabel,
                        value: studentCode.isEmpty ? '—' : studentCode,
                      ),
                    if (isStudent)
                      Divider(height: 1, indent: 50, endIndent: 12, color: theme.dividerColor.withValues(alpha: 0.28)),
                    _ProfileInfoRow(
                      icon: Icons.phone_outlined,
                      iconColor: AppColors.success,
                      iconBg: AppColors.success.withValues(alpha: 0.12),
                      label: t.profilePhoneLabel,
                      value: phone.isEmpty ? '—' : phone,
                    ),
                    Divider(height: 1, indent: 50, endIndent: 12, color: theme.dividerColor.withValues(alpha: 0.28)),
                    _ProfileInfoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFF6366F1),
                      iconBg: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      label: t.profileAddressLabel,
                      value: address.isEmpty ? '—' : address,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileDetailCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileDetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: AppTextStyles.body.copyWith(fontSize: 14.5, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
