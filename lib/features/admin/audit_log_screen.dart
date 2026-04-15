import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// Nhật ký thao tác — chỉ Admin đọc được (Firestore).
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _searchController = TextEditingController();
  static const _all = 'all';
  String _filterAction = _all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ({IconData icon, Color color, String label}) _actionMeta(ThemeData theme, String actionRaw) {
    final a = actionRaw.trim().toLowerCase();
    switch (a) {
      case 'role_change':
        return (icon: Icons.badge_outlined, color: const Color(0xFF7C3AED), label: 'Role');
      case 'user_lock':
        return (icon: Icons.lock_outline, color: const Color(0xFFDC2626), label: 'Lock');
      case 'user_unlock':
        return (icon: Icons.lock_open_outlined, color: const Color(0xFF059669), label: 'Unlock');
      case 'library_config':
        return (icon: Icons.tune_rounded, color: const Color(0xFF2563EB), label: 'Config');
      default:
        return (icon: Icons.bolt_rounded, color: theme.colorScheme.primary, label: actionRaw.isEmpty ? '—' : actionRaw);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!AppUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(t.auditLogTitle)),
        body: Center(child: Text(t.auditLogAdminOnly)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.auditLogTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('audit_logs')
            .orderBy('createdAt', descending: true)
            .limit(200)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(t.auditLogLoadError('${snapshot.error}')));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text(t.auditLogEmpty));
          }

          final q = _searchController.text.trim().toLowerCase();
          final filtered = docs.where((doc) {
            final d = doc.data();
            final action = '${d['action'] ?? ''}'.trim();
            if (_filterAction != _all && action.trim().toLowerCase() != _filterAction) return false;
            if (q.isEmpty) return true;
            final actor = '${d['actorEmail'] ?? d['actorUid'] ?? ''}'.toLowerCase();
            final detail = '${d['detail'] ?? ''}'.toLowerCase();
            final target = '${d['targetUserId'] ?? ''}'.toLowerCase();
            return actor.contains(q) || detail.contains(q) || target.contains(q) || action.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
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
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          (_all, 'All'),
                          ('role_change', 'Role'),
                          ('user_lock', 'Lock'),
                          ('user_unlock', 'Unlock'),
                          ('library_config', 'Config'),
                        ].map((e) {
                          final code = e.$1;
                          final label = e.$2;
                          final selected = _filterAction == code;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label, style: const TextStyle(fontSize: 12.5)),
                              selected: selected,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onSelected: (_) => setState(() => _filterAction = code),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(t.statsNoChartData, style: TextStyle(color: theme.hintColor)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final d = filtered[i].data();
                          final action = '${d['action'] ?? '—'}';
                          final actor = '${d['actorEmail'] ?? d['actorUid'] ?? '—'}';
                          final detail = '${d['detail'] ?? ''}'.trim();
                          final target = '${d['targetUserId'] ?? ''}'.trim();
                          final ts = d['createdAt'];
                          String timeStr = '—';
                          if (ts is Timestamp) {
                            final dt = ts.toDate().toLocal();
                            timeStr =
                                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                          }
                          final meta = _actionMeta(theme, action);
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.28)),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: meta.color.withValues(alpha: 0.12),
                                child: Icon(meta.icon, color: meta.color, size: 18),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      actor,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(timeStr, style: AppTextStyles.caption),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: meta.color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            meta.label,
                                            style: AppTextStyles.small.copyWith(
                                              color: meta.color,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        if (target.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              'uid: $target',
                                              style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (detail.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        detail,
                                        style: theme.textTheme.bodySmall?.copyWith(height: 1.25),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
