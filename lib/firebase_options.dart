// File generated manually from google-services.json
// Run: dart run flutterfire_cli:flutterfire configure
// để sinh lại file đầy đủ cho iOS, Web, Windows khi cần.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions chưa cấu hình cho Web. '
        'Chạy: dart run flutterfire_cli:flutterfire configure',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions chưa cấu hình cho iOS. '
          'Chạy: dart run flutterfire_cli:flutterfire configure',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions chưa cấu hình cho macOS. '
          'Chạy: dart run flutterfire_cli:flutterfire configure',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions chưa cấu hình cho Windows. '
          'Chạy: dart run flutterfire_cli:flutterfire configure',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions chưa cấu hình cho Linux. '
          'Chạy: dart run flutterfire_cli:flutterfire configure',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions không hỗ trợ platform: $defaultTargetPlatform',
        );
    }
  }

  /// Cấu hình Android từ google-services.json (project: applibrarysystem)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4ivpPiEVxmTwX2i-8qim4SV3_bUhIm9c',
    appId: '1:632430558689:android:d1a88c0dc9d30ff5ae66a0',
    messagingSenderId: '632430558689',
    projectId: 'applibrarysystem',
    storageBucket: 'applibrarysystem.firebasestorage.app',
  );
}
