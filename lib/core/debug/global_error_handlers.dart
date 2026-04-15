import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../gen/l10n/app_localizations.dart';

/// Gắn trước [runApp]: in lỗi ra console (debugPrint) và hiển thị lỗi cụ thể trên màn hình
/// khi widget build lỗi ([ErrorWidget]), thay vì chỉ màn đỏ chung.
void setupGlobalErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('═══ FlutterError ═══');
      debugPrint(details.exceptionAsString());
      if (details.stack != null) {
        debugPrint(details.stack.toString());
      }
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('═══ Uncaught async/zone error ═══');
      debugPrint('$error');
      debugPrint(stack.toString());
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    final msg = details.exceptionAsString();
    return Builder(
      builder: (context) {
        var locale = Localizations.maybeLocaleOf(context) ?? const Locale('vi');
        if (!<String>{'en', 'vi'}.contains(locale.languageCode)) {
          locale = const Locale('vi');
        }
        final t = lookupAppLocalizations(locale);
        final stack = details.stack?.toString() ?? t.errorNoStack;
        final screenH = MediaQuery.sizeOf(context).height;
        final scrollH = math.max(200.0, math.min(screenH * 0.55, 720.0));
        return Material(
          color: const Color(0xFF1E1E1E),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          kDebugMode ? t.errorWidgetDebugTitle : t.errorWidgetReleaseTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kDebugMode ? t.errorWidgetDebugDetailHint : t.errorWidgetReleaseHint,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: scrollH,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.5)),
                      ),
                      child: SelectionArea(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            '$msg\n\n$stack',
                            style: const TextStyle(
                              color: Color(0xFFE0E0E0),
                              fontSize: 12,
                              height: 1.35,
                              fontFamily: 'monospace',
                              fontFamilyFallback: ['Consolas', 'monospace'],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  };
}
