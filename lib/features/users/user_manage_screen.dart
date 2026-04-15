import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/audit_log_service.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình quản lý người dùng & trạng thái tài khoản (chỉ Admin)
class UserManageScreen extends StatefulWidget {
  const UserManageScreen({super.key});

  @override
  State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  final _searchController = TextEditingController();
  static const _roleAll = 'all';
  String _filterRole = _roleAll;
  bool _denseMode = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _setRole(_UserItem u, String newRole) async {
    final t = AppLocalizations.of(context)!;
    final r = newRole.trim().toLowerCase();
    if (r == u.role) return;

    if (u.role == 'admin' && r != 'admin') {
      final admins = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      if (admins.docs.length <= 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.userManageCannotRemoveLastAdmin)),
          );
        }
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(u.id).update({'role': r});
      await AuditLogService.roleChanged(targetUserId: u.id, fromRole: u.role, toRole: r);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.userManageRoleChanged)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.userManageRoleError('$e'))),
        );
      }
    }
  }

  void _showRoleSheet(_UserItem u) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.userManagePickRole, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(t.userFilterAdmin),
              trailing: u.role == 'admin' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                Navigator.pop(ctx);
                _setRole(u, 'admin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(t.userFilterManager),
              trailing: u.role == 'manager' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                Navigator.pop(ctx);
                _setRole(u, 'manager');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(t.userFilterStudent),
              trailing: u.role != 'admin' && u.role != 'manager'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                _setRole(u, 'student');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.usersManageTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.staffOnlyUserManage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final readOnly = !AppUser.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.usersManageTitle),
      ),
      body: Column(
        children: [
          if (!readOnly)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.userManageStaffHintBody,
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: t.searchUsersHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.trim().isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            (_roleAll, t.userFilterAll),
                            ('admin', t.userFilterAdmin),
                            ('manager', t.userFilterManager),
                            ('student', t.userFilterStudent),
                          ].map((e) {
                            final code = e.$1;
                            final label = e.$2;
                            final selected = _filterRole == code;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label, style: const TextStyle(fontSize: 12.5)),
                                selected: selected,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onSelected: (_) => setState(() => _filterRole = code),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Dense',
                      child: IconButton(
                        onPressed: () => setState(() => _denseMode = !_denseMode),
                        icon: Icon(_denseMode ? Icons.view_agenda_outlined : Icons.view_day_outlined),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(t.cannotLoadUsers));
                }

                final docs = snapshot.data?.docs ?? [];
                var users = docs.map(_UserItem.fromDoc).toList();

                if (_filterRole == 'admin') {
                  users = users.where((u) => u.role == 'admin').toList();
                } else if (_filterRole == 'manager') {
                  users = users.where((u) => u.role == 'manager').toList();
                } else if (_filterRole == 'student') {
                  users = users.where((u) => u.role == 'student').toList();
                }

                final q = _searchController.text.trim().toLowerCase();
                if (q.isNotEmpty) {
                  users = users.where((u) {
                    return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(child: Text(t.noUsersYet));
                }

                users.sort((a, b) {
                  int rank(String r) {
                    if (r == 'admin') return 0;
                    if (r == 'manager') return 1;
                    return 2;
                  }

                  final ar = rank(a.role);
                  final br = rank(b.role);
                  if (ar != br) return ar.compareTo(br);
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    final locked = !u.isActive;
                    final t2 = AppLocalizations.of(context)!;
                    final displayName = u.name.trim().isNotEmpty ? u.name.trim() : t2.userNamePlaceholder;
                    final displayEmail = u.email.trim().isNotEmpty ? u.email.trim() : 'UID: ${u.id}';
                    final roleLabel = _UserItem.roleLabelLocalized(AppLocalizations.of(context)!, u.role);
                    final roleColor = switch (u.role) {
                      'admin' => const Color(0xFF7C3AED),
                      'manager' => const Color(0xFF2563EB),
                      _ => const Color(0xFF059669),
                    };

                    final card = DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.28)),
                      ),
                      child: ListTile(
                        dense: _denseMode,
                        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: (locked ? AppColors.error : AppColors.primary).withValues(alpha: 0.12),
                          child: Icon(Icons.person, color: locked ? AppColors.error : AppColors.primary),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: AppTextStyles.h3.copyWith(fontSize: 15.0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                roleLabel,
                                style: AppTextStyles.small.copyWith(
                                  color: roleColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (locked) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.lockedLabel,
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            displayEmail,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                            ),
                            maxLines: _denseMode ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: readOnly
                            ? null
                            : ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 92),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: t.userManageChangeRole,
                                      icon: const Icon(Icons.badge_outlined),
                                      onPressed: () => _showRoleSheet(u),
                                    ),
                                    Transform.scale(
                                      scale: 0.85,
                                      child: Switch.adaptive(
                                        value: u.isActive,
                                        onChanged: (v) => _toggleActive(u, v),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: card,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(_UserItem u, bool isActive) async {
    final t = AppLocalizations.of(context)!;
    final self = FirebaseAuth.instance.currentUser?.uid == u.id;
    if (!isActive && self) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.userManageCannotLockSelf)),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(u.id).update({'isActive': isActive});
      await AuditLogService.userActiveToggled(targetUserId: u.id, isActive: isActive);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.cannotUpdateStatus('$e'))),
      );
    }
  }
}

class _UserItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  static String roleLabelLocalized(AppLocalizations t, String role) {
    switch (role.trim().toLowerCase()) {
      case 'admin':
        return t.roleLabelAdminShort;
      case 'manager':
        return t.roleLabelManagerShort;
      default:
        return t.roleLabelStudentShort;
    }
  }

  _UserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  static bool _asBool(dynamic v, {required bool fallback}) {
    if (v is bool) return v;
    if (v == null) return fallback;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  factory _UserItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawName = data['fullName'] ?? data['name'];
    final rawEmail = data['email'];
    final rawRole = data['role'];
    final rawActive = data['isActive'];
    return _UserItem(
      id: doc.id,
      name: (rawName ?? '').toString().trim(),
      email: (rawEmail ?? '').toString().trim(),
      role: (rawRole ?? 'student').toString().trim(),
      isActive: _asBool(rawActive, fallback: true),
    );
  }
}
