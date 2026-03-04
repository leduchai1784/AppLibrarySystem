import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/constants/app_constants.dart';

/// Service xử lý đăng nhập, đăng ký và quản lý phiên Firebase Auth
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

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

    // Nếu user chưa có trong collection users thì tạo mới với role mặc định là student
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      await userDocRef.set({
        'uid': user.uid,
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'student',
        'studentCode': '',
        'phone': user.phoneNumber ?? '',
        'avatarUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'totalBorrowed': 0,
      });
    }

    await _loadUserRole(user.uid);
  }

  /// Tải lại role khi mở app (user đã đăng nhập sẵn)
  static Future<void> reloadUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _loadUserRole(user.uid);
    }
  }

  /// Lấy role từ Firestore và cập nhật AppUser
  static Future<void> _loadUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      AppUser.setRole(UserRole.student);
      return;
    }

    final data = doc.data();
    final roleStr = data?['role'] as String? ?? 'student';

    AppUser.setRole(
      roleStr == 'admin' ? UserRole.admin : UserRole.student,
    );
  }

  /// Đăng xuất
  static Future<void> signOut() async {
    await _auth.signOut();
    AppUser.clear();
  }

  /// Kiểm tra đã đăng nhập chưa
  static User? get currentUser => _auth.currentUser;
}
