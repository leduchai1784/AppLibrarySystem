import 'package:cloud_firestore/cloud_firestore.dart';

import 'library_config_service.dart';

/// Feature flags lưu trong `library_settings/config.features`.
///
/// Ví dụ schema:
/// {
///   features: {
///     scanEnabled: true,
///     borrowReturnEnabled: true,
///     aiRecommendationsEnabled: true,
///     statisticsEnabled: true
///   }
/// }
class FeatureFlagsService {
  FeatureFlagsService._();

  static const String _featuresKey = 'features';

  static const String scanEnabled = 'scanEnabled';
  static const String borrowReturnEnabled = 'borrowReturnEnabled';
  static const String aiRecommendationsEnabled = 'aiRecommendationsEnabled';
  static const String statisticsEnabled = 'statisticsEnabled';

  static Map<String, bool> defaults() => const <String, bool>{
        scanEnabled: true,
        borrowReturnEnabled: true,
        aiRecommendationsEnabled: true,
        statisticsEnabled: true,
      };

  static Stream<Map<String, bool>> watchFlags() {
    return LibraryConfigService.configRef.snapshots().map((snap) {
      final data = snap.data() ?? {};
      final raw = data[_featuresKey];
      final base = defaults();
      if (raw is Map) {
        for (final e in raw.entries) {
          final k = e.key.toString();
          final v = e.value;
          if (v is bool && base.containsKey(k)) {
            base[k] = v;
          }
        }
      }
      return base;
    });
  }

  static bool flag(Map<String, bool>? flags, String key) {
    final d = defaults();
    if (flags == null) return d[key] ?? true;
    return flags[key] ?? d[key] ?? true;
  }

  static Future<void> saveFlags(Map<String, bool> flags) async {
    await LibraryConfigService.configRef.set(
      <String, dynamic>{
        _featuresKey: flags,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

