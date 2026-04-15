import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/constants/app_constants.dart';

/// Service xử lý đăng nhập, đăng ký và quản lý phiên Firebase Auth
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// Trên web cần Web client ID (cùng project Firebase; có trong Google Cloud → Credentials → OAuth client Web).
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '632430558689-eg99tnmudgpkut90lh0angbch8spdtsa.apps.googleusercontent.com' : null,
  );

  /// Đăng nhập bằng email & mật khẩu
  static Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    await _loadUserRole(user.uid);
  }

  /// Đăng ký tài khoản mới (mặc định role = student)
  static Future<void> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'role': 'student',
      'studentCode': '',
      'phone': phone.trim(),
      'avatarUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'totalBorrowed': 0,
    });

    await user.sendEmailVerification();

    AppUser.setRole(UserRole.student);
  }

  /// Đăng nhập bằng Google
  static Future<void> signInWithGoogle() async {
    // Ép hiện màn chọn tài khoản (tránh tự dùng tài khoản đăng nhập trước đó)
    await _googleSignIn.signOut();
    // Một số máy cần disconnect để chắc chắn hiện account chooser
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // ignore
    }

    // Mở màn hình chọn tài khoản Google
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // Người dùng hủy chọn tài khoản
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return;

    await _ensureUserDocUpsert(user);

    await _loadUserRole(user.uid);
  }

  /// Tải lại role khi mở app (user đã đăng nhập sẵn)
  static Future<void> reloadUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _ensureUserDocUpsert(user);
      await _loadUserRole(user.uid);
    }
  }

  static Future<void> _ensureUserDocUpsert(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final snap = await userDocRef.get();
    final data = snap.data();

    final existingName = (data?['fullName'] ?? data?['name'])?.toString().trim() ?? '';
    final existingRole = (data?['role'])?.toString().trim().toLowerCase() ?? '';
    final existingPhone = (data?['phone'])?.toString().trim() ?? '';
    final existingAvatar = (data?['avatarUrl'])?.toString().trim() ?? '';
    final existingEmail = (data?['email'])?.toString().trim() ?? '';
    final hasActive = data?.containsKey('isActive') ?? false;

    final patch = <String, dynamic>{
      'uid': user.uid,
    };

    // Role: chỉ set mặc định nếu thiếu
    if (existingRole.isEmpty) {
      patch['role'] = 'student';
    }

    // isActive: mặc định true nếu thiếu
    if (!hasActive) {
      patch['isActive'] = true;
    }

    // Email: ưu tiên email từ Auth (nếu có), tránh doc bị rỗng
    final authEmail = (user.email ?? '').trim();
    if (authEmail.isNotEmpty && authEmail != existingEmail) {
      patch['email'] = authEmail;
    }

    // fullName: chỉ bù nếu doc đang rỗng (tránh ghi đè tên người dùng đã chỉnh)
    final authName = (user.displayName ?? '').trim();
    if (existingName.isEmpty && authName.isNotEmpty) {
      patch['fullName'] = authName;
    }

    // Phone + avatar: chỉ bù nếu doc đang rỗng
    final authPhone = (user.phoneNumber ?? '').trim();
    if (existingPhone.isEmpty && authPhone.isNotEmpty) {
      patch['phone'] = authPhone;
    }

    final authAvatar = (user.photoURL ?? '').trim();
    if (existingAvatar.isEmpty && authAvatar.isNotEmpty) {
      patch['avatarUrl'] = authAvatar;
    }

    if (!snap.exists) {
      await userDocRef.set({
        ...patch,
        'fullName': patch['fullName'] ?? authName,
        'email': patch['email'] ?? authEmail,
        'studentCode': '',
        'phone': patch['phone'] ?? authPhone,
        'avatarUrl': patch['avatarUrl'] ?? authAvatar,
        'createdAt': FieldValue.serverTimestamp(),
        'totalBorrowed': 0,
      });
      return;
    }

    if (patch.length <= 1) return; // chỉ có uid, không cần ghi
    await userDocRef.set(patch, SetOptions(merge: true));
  }

  /// Lấy role từ Firestore và cập nhật AppUser
  static Future<void> _loadUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      AppUser.setRole(UserRole.student);
      return;
    }

    final data = doc.data();
    final rawRole = data?['role'];
    final roleStr = (rawRole is String ? rawRole : rawRole?.toString() ?? 'student').trim().toLowerCase();

    final role = switch (roleStr) {
      'admin' => UserRole.admin,
      'manager' => UserRole.manager,
      _ => UserRole.student,
    };
    AppUser.setRole(role);
  }

  /// Trên web: nếu không phải admin/manager thì đăng xuất (gọi sau khi role đã nạp vào [AppUser]).
  /// Trả về `true` nếu đã từ chối và đã đăng xuất.
  static Future<bool> rejectWebSessionIfNotStaff() async {
    if (!kIsWeb) return false;
    if (AppUser.isStaff) return false;
    await signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    return true;
  }

  /// Trên Android/iOS: tài khoản **admin** chỉ dùng cổng web (theo chính sách nền tảng).
  /// Quản lý và sinh viên vẫn dùng app. Trả về `true` nếu đã từ chối và đăng xuất.
  static Future<bool> rejectMobileSessionIfAdmin() async {
    if (kIsWeb) return false;
    if (!AppUser.isAdmin) return false;
    await signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    return true;
  }

  /// Đăng xuất
  static Future<void> signOut() async {
    await _auth.signOut();
    AppUser.clear();
  }

  /// Kiểm tra đã đăng nhập chưa
  static User? get currentUser => _auth.currentUser;
}
