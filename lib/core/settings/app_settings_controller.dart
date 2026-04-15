import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cài đặt giao diện / ngôn ngữ / tùy chọn mobile (SharedPreferences).
class AppSettingsController extends ChangeNotifier {
  AppSettingsController._({
    required SharedPreferences prefs,
    required ThemeMode themeMode,
    required Locale locale,
    required int qrColorArgb,
    required int qrSizeLevel,
    required bool scannerAutofocus,
    required bool scannerSound,
    required bool pushNotificationsEnabled,
  })  : _prefs = prefs,
        _themeMode = themeMode,
        _locale = locale,
        _qrColorArgb = qrColorArgb,
        _qrSizeLevel = qrSizeLevel.clamp(0, 2),
        _scannerAutofocus = scannerAutofocus,
        _scannerSound = scannerSound,
        _pushNotificationsEnabled = pushNotificationsEnabled;

  static const _keyTheme = 'web_theme_mode';
  static const _keyLocale = 'web_locale';
  static const _keyQrColor = 'mobile_qr_color_argb';
  static const _keyQrSize = 'mobile_qr_size_level';
  static const _keyScannerAutofocus = 'mobile_scanner_autofocus';
  static const _keyScannerSound = 'mobile_scanner_sound';
  static const _keyPushEnabled = 'mobile_push_enabled';

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  /// Mặc định xanh primary app.
  static const int defaultQrColorArgb = 0xFF1E94F6;

  final SharedPreferences _prefs;
  ThemeMode _themeMode;
  Locale _locale;
  int _qrColorArgb;
  int _qrSizeLevel;
  bool _scannerAutofocus;
  bool _scannerSound;
  bool _pushNotificationsEnabled;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Color get qrDefaultColor => Color(_qrColorArgb);
  int get qrSizeLevel => _qrSizeLevel;

  /// Kích thước QR xem trước / mặc định (px).
  double get qrDefaultPixelSize {
    switch (_qrSizeLevel) {
      case 0:
        return 200;
      case 2:
        return 300;
      default:
        return 256;
    }
  }

  bool get scannerAutofocusEnabled => _scannerAutofocus;
  bool get scannerSoundEnabled => _scannerSound;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  static Future<AppSettingsController> load() async {
    final p = await SharedPreferences.getInstance();
    final themeStr = p.getString(_keyTheme) ?? 'system';
    final locCode = p.getString(_keyLocale) ?? 'vi';
    return AppSettingsController._(
      prefs: p,
      themeMode: _themeModeFromStorage(themeStr),
      locale: Locale(locCode),
      qrColorArgb: p.getInt(_keyQrColor) ?? defaultQrColorArgb,
      qrSizeLevel: p.getInt(_keyQrSize) ?? 1,
      scannerAutofocus: p.getBool(_keyScannerAutofocus) ?? true,
      scannerSound: p.getBool(_keyScannerSound) ?? false,
      pushNotificationsEnabled: p.getBool(_keyPushEnabled) ?? false,
    );
  }

  static ThemeMode _themeModeFromStorage(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get themeModeStorageValue {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(_keyTheme, themeModeStorageValue);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    if (!supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    _locale = locale;
    await _prefs.setString(_keyLocale, locale.languageCode);
    notifyListeners();
  }

  Future<void> setQrDefaultColor(Color color) async {
    final v = color.toARGB32();
    if (_qrColorArgb == v) return;
    _qrColorArgb = v;
    await _prefs.setInt(_keyQrColor, v);
    notifyListeners();
  }

  Future<void> setQrSizeLevel(int level) async {
    final l = level.clamp(0, 2);
    if (_qrSizeLevel == l) return;
    _qrSizeLevel = l;
    await _prefs.setInt(_keyQrSize, l);
    notifyListeners();
  }

  Future<void> setScannerAutofocus(bool v) async {
    if (_scannerAutofocus == v) return;
    _scannerAutofocus = v;
    await _prefs.setBool(_keyScannerAutofocus, v);
    notifyListeners();
  }

  Future<void> setScannerSound(bool v) async {
    if (_scannerSound == v) return;
    _scannerSound = v;
    await _prefs.setBool(_keyScannerSound, v);
    notifyListeners();
  }

  Future<void> setPushNotificationsEnabled(bool v) async {
    if (_pushNotificationsEnabled == v) return;
    _pushNotificationsEnabled = v;
    await _prefs.setBool(_keyPushEnabled, v);
    notifyListeners();
  }

  /// Xóa toàn bộ khóa cài đặt do app tạo (không xóa dữ liệu Firestore).
  Future<void> clearAllAppPreferences() async {
    const keys = <String>{
      _keyTheme,
      _keyLocale,
      _keyQrColor,
      _keyQrSize,
      _keyScannerAutofocus,
      _keyScannerSound,
      _keyPushEnabled,
    };
    for (final k in keys) {
      await _prefs.remove(k);
    }
    _themeMode = ThemeMode.system;
    _locale = const Locale('vi');
    _qrColorArgb = defaultQrColorArgb;
    _qrSizeLevel = 1;
    _scannerAutofocus = true;
    _scannerSound = false;
    _pushNotificationsEnabled = false;
    notifyListeners();
  }
}
