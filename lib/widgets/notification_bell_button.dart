import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Nút chuông + số thông báo chưa đọc (theo snapshot Firestore gần nhất).
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return IconButton(
        icon: const Icon(Icons.notifications_none),
        onPressed: onPressed,
      );
    }

    Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection('notifications');
    if (!AppUser.isStaff) {
      q = q.where('userId', isEqualTo: uid);
    }
    q = q.orderBy('createdAt', descending: true).limit(40);

    return IconButton(
      onPressed: onPressed,
      icon: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? const [];
          final unread = docs.where((d) => d.data()['read'] != true).length;
          final label = unread > 99 ? '99+' : (unread == 0 ? '' : '$unread');
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none),
              if (label.isNotEmpty)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
