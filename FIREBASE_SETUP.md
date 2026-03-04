# Kết nối Firebase - Library System

## Đã cấu hình

- **firebase_core** – Khởi tạo Firebase  
- **firebase_auth** – Xác thực người dùng  
- **applicationId Android** – `com.company.librarysystemapp` (phù hợp với Firebase Console)  
- **Google Services plugin** – Đã thêm trong Gradle  

## Bước cần làm

### 1. Tải `google-services.json` từ Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com/)  
2. Chọn project **LibrarySystemApp**  
3. Vào **Project Settings** (bánh răng) → **Your apps**  
4. Nhấn nút **Télécharger google-services.json** (Download google-services.json)  
5. Đặt file vào thư mục `android/app/` của project  

```
library_system/
  android/
    app/
      google-services.json   ← Đặt file ở đây
      build.gradle.kts
      ...
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Chạy ứng dụng

```bash
flutter run
```

## (Tùy chọn) Cấu hình bằng FlutterFire CLI

Nếu muốn tạo `firebase_options.dart` cho iOS/Web:

```bash
# Đăng nhập Firebase
firebase login

# Cấu hình FlutterFire (tạo firebase_options.dart)
dart run flutterfire_cli:flutterfire configure
```

Sau đó cập nhật `main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LibrarySystemApp());
}
```

## Thêm SHA-1 cho Google Sign-In

Nếu dùng **Google Sign-In**, cần thêm SHA-1:

```bash
cd android
./gradlew signingReport
```

Lấy SHA-1 và thêm vào Firebase Console → Project Settings → Your apps → Add fingerprint.
