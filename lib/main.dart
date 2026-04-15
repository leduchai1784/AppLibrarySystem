import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/debug/global_error_handlers.dart';
import 'services/push_notification_service.dart';
import 'gen/l10n/app_localizations.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setupGlobalErrorHandlers();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    PushNotificationService.registerBackgroundHandler();
    await PushNotificationService.initializeForegroundListeners();
    final appSettings = await AppSettingsController.load();
    runApp(
      ChangeNotifierProvider<AppSettingsController>.value(
        value: appSettings,
        child: const LibrarySystemApp(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushNotificationService.attachAuthListener();
    });
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('═══ runZonedGuarded (lỗi không bắt được trong async) ═══');
      debugPrint('$error');
      debugPrint('$stack');
    }
  });
}

class LibrarySystemApp extends StatelessWidget {
  const LibrarySystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsController>(
      builder: (context, appSettings, _) {
        return MaterialApp(
          navigatorKey: AppRoutes.rootNavigatorKey,
          navigatorObservers: [AppRoutes.routeObserver],
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appSettings.themeMode,
          locale: appSettings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          initialRoute: AppRoutes.authCheck,
          routes: AppRoutes.routes,
          builder: (context, child) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
