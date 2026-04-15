import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/borrow_policy.dart';

/// Đọc `library_settings/config` — chỉnh qua [LibraryBusinessSettingsScreen] (admin).
class LibraryConfigService {
  LibraryConfigService._();

  static const String collection = 'library_settings';
  static const String configDocId = 'config';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get configRef =>
      _db.collection(collection).doc(configDocId);

  static Future<Map<String, dynamic>> getConfigMap() async {
    final snap = await configRef.get();
    return snap.data() ?? {};
  }

  /// Gợi ý ngày mượn (7–14) lưu trong Firestore.
  static Future<int> loanDaysSuggested() async {
    final m = await getConfigMap();
    final v = m['loanDays'];
    if (v is int && v > 0) {
      return BorrowPolicy.clampConfigToSuggestedRange(v);
    }
    return BorrowPolicy.defaultLoanDays;
  }

  /// Số phiếu đang mượn tối đa cho một user (mặc định 5).
  static Future<int> maxActiveBorrowsPerUser() async {
    final m = await getConfigMap();
    final v = m['maxActiveBorrowsPerUser'];
    if (v is int && v > 0) {
      return v.clamp(1, 99);
    }
    return 5;
  }

}
