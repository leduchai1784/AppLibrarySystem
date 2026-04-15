import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// Thông báo từ Firestore (`notifications`) — cập nhật realtime.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.notificationsTitle)),
        body: Center(child: Text(t.commonSignIn)),
      );
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('notifications');
    if (!AppUser.isStaff) {
      query = query.where('userId', isEqualTo: uid);
    }
    query = query.orderBy('createdAt', descending: true).limit(80);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationsTitle),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(context, uid),
            child: Text(t.markAllRead),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t.notifLoadFailed('${snapshot.error}'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                AppUser.isStaff ? t.notifEmptyStaff : t.notifEmptyStudent,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final data = d.data();
              final loc = AppLocalizations.of(context)!;
              final title = (data['title'] ?? loc.pushFallbackTitle) as String;
              final body = (data['body'] ?? '') as String;
              final read = data['read'] == true;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final time = _formatRelative(createdAt, loc);

              Color iconColor = AppColors.primary;
              final titleLower = title.toLowerCase();
              if (titleLower.contains('hạn') ||
                  titleLower.contains('trễ') ||
                  titleLower.contains('late') ||
                  titleLower.contains('due') ||
                  titleLower.contains('overdue')) {
                iconColor = AppColors.warning;
              }
              if (titleLower.contains('trả') || titleLower.contains('return')) {
                iconColor = AppColors.success;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: read ? null : AppColors.primary.withValues(alpha: 0.04),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withValues(alpha: 0.2),
                    child: Icon(Icons.notifications, color: iconColor),
                  ),
                  title: Text(title, style: AppTextStyles.h3),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(body, style: AppTextStyles.body),
                      const SizedBox(height: 4),
                      Text(time, style: AppTextStyles.small),
                    ],
                  ),
                  onTap: () async {
                    if (read) return;
                    try {
                      await d.reference.update({'read': true});
                    } catch (_) {}
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatRelative(DateTime? dt, AppLocalizations t) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return t.timeJustNow;
    if (diff.inMinutes < 60) return t.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return t.timeAgoHours(diff.inHours);
    if (diff.inDays < 7) return t.timeAgoDays(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static Future<void> _markAllRead(BuildContext context, String uid) async {
    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection('notifications');
      if (!AppUser.isStaff) {
        q = q.where('userId', isEqualTo: uid);
      }
      final snap = await q.limit(200).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final d in snap.docs) {
        if (d.data()['read'] != true) {
          batch.update(d.reference, {'read': true});
        }
      }
      await batch.commit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.markedAllRead)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPrefix('$e'))),
        );
      }
    }
  }
}
