import '../../gen/l10n/app_localizations.dart';

/// Chuẩn hoá nhãn danh mục khi DB còn giá trị mặc định tiếng Việt / English.
String displayBookCategory(AppLocalizations t, String category) {
  final c = category.trim();
  if (c.isEmpty || c == 'Khác' || c == 'Other') return t.categoryOther;
  return c;
}
