import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../gen/l10n/app_localizations.dart';

Future<AppLocalizations> _pushL10n() async {
  final p = await SharedPreferences.getInstance();
  final code = (p.getString('web_locale') ?? 'vi').split('_').first;
  final lang = code == 'en' ? 'en' : 'vi';
  return lookupAppLocalizations(Locale(lang));
}

/// Đồng bộ khóa với [AppSettingsController._keyPushEnabled] — giữ string khớp.
const String kPrefsKeyPushNotifications = 'mobile_push_enabled';

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

bool _nativeMobilePush() => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

bool _localNotificationsReady = false;
StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreMirrorSub;
StreamSubscription<User?>? _authSub;
bool _tokenRefreshHooked = false;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _ensureLocalNotificationsInitialized();
  await _showNotificationFromRemote(message);
}

Future<void> _ensureLocalNotificationsInitialized() async {
  if (_localNotificationsReady) return;
  final loc = await _pushL10n();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  await _localNotifications.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );

  if (Platform.isAndroid) {
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            'library_channel',
            loc.pushChannelName,
            description: loc.pushChannelDescription,
            importance: Importance.defaultImportance,
          ),
        );
  }
  _localNotificationsReady = true;
}

Future<void> _showNotificationFromRemote(RemoteMessage message) async {
  await _ensureLocalNotificationsInitialized();
  final loc = await _pushL10n();
  final n = message.notification;
  final title = n?.title ?? message.data['title']?.toString() ?? loc.pushDefaultTitle;
  final body = n?.body ?? message.data['body']?.toString() ?? '';
  await _showLocalNotification(title, body, id: message.hashCode.abs() % 2000000000);
}

Future<void> _showLocalNotification(String title, String body, {required int id}) async {
  await _ensureLocalNotificationsInitialized();
  final loc = await _pushL10n();
  final androidDetails = AndroidNotificationDetails(
    'library_channel',
    loc.pushChannelName,
    channelDescription: loc.pushChannelDescription,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  const iosDetails = DarwinNotificationDetails();
  await _localNotifications.show(
    id,
    title,
    body.isEmpty ? ' ' : body,
    NotificationDetails(android: androidDetails, iOS: iosDetails),
  );
}

/// FCM + hiển thị local khi có thông báo mới trên Firestore (không cần Cloud Function).
class PushNotificationService {
  PushNotificationService._();

  /// Gọi một lần sau [Firebase.initializeApp], trước [runApp].
  static void registerBackgroundHandler() {
    if (!_nativeMobilePush()) return;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> initializeForegroundListeners() async {
    if (!_nativeMobilePush()) return;
    await _ensureLocalNotificationsInitialized();

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(kPrefsKeyPushNotifications) != true) return;
      await _showNotificationFromRemote(message);
    });
  }

  static Future<void> attachAuthListener() async {
    if (!_nativeMobilePush()) return;
    await _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      await _firestoreMirrorSub?.cancel();
      _firestoreMirrorSub = null;
      if (user == null) return;
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(kPrefsKeyPushNotifications) == true) {
        await requestPermissionAndRegisterToken(user.uid);
        await _startFirestoreMirror(user.uid);
      }
    });
  }

  static Future<void> requestPermissionAndRegisterToken(String uid) async {
    if (!_nativeMobilePush()) return;
    await _ensureLocalNotificationsInitialized();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'fcmTokens': FieldValue.arrayUnion([token])},
      SetOptions(merge: true),
    );
    if (!_tokenRefreshHooked) {
      _tokenRefreshHooked = true;
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final u = FirebaseAuth.instance.currentUser;
        if (u == null) return;
        await FirebaseFirestore.instance.collection('users').doc(u.uid).set(
          {'fcmTokens': FieldValue.arrayUnion([newToken])},
          SetOptions(merge: true),
        );
      });
    }
  }

  static Future<void> onPushSettingChanged({
    required bool enabled,
    required String? uid,
  }) async {
    if (!_nativeMobilePush()) return;
    await _firestoreMirrorSub?.cancel();
    _firestoreMirrorSub = null;
    if (!enabled || uid == null) return;
    await requestPermissionAndRegisterToken(uid);
    await _startFirestoreMirror(uid);
  }

  static Future<void> _startFirestoreMirror(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = (userDoc.data()?['role'] ?? '').toString().toLowerCase().trim();
    final isStaff = role == 'admin' || role == 'manager';

    final Query<Map<String, dynamic>> q = isStaff
        ? FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(30)
        : FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(30);

    var firstSnapshot = true;
    await _firestoreMirrorSub?.cancel();
    _firestoreMirrorSub = q.snapshots().listen((snap) {
      if (firstSnapshot) {
        firstSnapshot = false;
        return;
      }
      for (final change in snap.docChanges) {
        if (change.type != DocumentChangeType.added) continue;
        final d = change.doc.data();
        if (d == null) continue;
        if (d['read'] == true) continue;
        if (!isStaff && d['userId'] != uid) continue;
        unawaited(() async {
          final loc = await _pushL10n();
          final title = (d['title'] ?? loc.pushFallbackTitle).toString();
          final body = (d['body'] ?? '').toString();
          await _showLocalNotification(title, body, id: change.doc.id.hashCode.abs() % 2000000000);
        }());
      }
    });
  }
}
