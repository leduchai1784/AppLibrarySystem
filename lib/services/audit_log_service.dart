import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Nhật ký thao tác — collection `audit_logs` (đọc: admin).
class AuditLogService {
  AuditLogService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _col => _db.collection('audit_logs');

  static Future<void> append({
    required String action,
    String? targetUserId,
    String? detail,
  }) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    await _col.add({
      'action': action,
      'actorUid': u.uid,
      'actorEmail': u.email,
      'targetUserId': targetUserId,
      'detail': detail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> roleChanged({
    required String targetUserId,
    required String fromRole,
    required String toRole,
  }) {
    return append(
      action: 'role_change',
      targetUserId: targetUserId,
      detail: '$fromRole -> $toRole',
    );
  }

  static Future<void> userActiveToggled({
    required String targetUserId,
    required bool isActive,
  }) {
    return append(
      action: isActive ? 'user_unlock' : 'user_lock',
      targetUserId: targetUserId,
      detail: 'isActive=$isActive',
    );
  }

  static Future<void> libraryConfigSaved(String summary) {
    return append(action: 'library_config', detail: summary);
  }
}
