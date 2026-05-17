# Luồng chức năng ứng dụng Library System

Tài liệu mô tả **luồng người dùng và nghiệp vụ** theo code hiện tại (Flutter + Firebase). Tham chi tiết schema Firestore tại [`DATABASE_SCHEMA.md`](DATABASE_SCHEMA.md).

---

## 1. Vai trò và nền tảng

| Vai trò (`users.role`) | Ý nghĩa trong app |
|------------------------|-------------------|
| `student` | Sinh viên: tra cứu sách, xem mượn/trả, thông báo, cài đặt cá nhân. |
| `manager` | Nhân sự thư viện: cùng portal vận hành với admin (trừ một số màn chỉ admin). |
| `admin` | Quản trị: đầy đủ cấu hình hệ thống, người dùng, audit log, v.v. |

**Ràng buộc phiên (quan trọng):**

1. **Email phải xác thực** — nếu chưa verify, app đăng xuất và đưa về đăng nhập.
2. **Web:** chỉ **nhân sự** (`admin` / `manager`) được dùng; sinh viên đăng nhập web sẽ bị chặn (`staffOnlyWeb`) và đưa về login kèm thông báo.
3. **App mobile:** tài khoản **`admin`** không được dùng (`adminUseWebOnly`) — phải dùng web; `manager` và `student` dùng bình thường.
4. **Đăng ký tài khoản mới:** route `/register` trên **web** không mở form — chỉ hiện màn thông báo (đăng ký qua app mobile).

---

## 2. Khởi động và điều hướng gốc

```text
[Mở app]
    → Firebase init, Firestore persistence, Push notification đăng ký
    → AppSettingsController (theme, locale, …)
    → Route ban đầu: /  [AuthCheckScreen]
```

**Luồng `AuthCheckScreen`:**

1. Chờ ngắn (~300ms).
2. **Chưa đăng nhập** → `pushReplacement` → `/login`.
3. **Đã đăng nhập:**
   - Email chưa verify → `signOut` → `/login`.
   - `reloadUserRole` (đồng bộ `AppUser` từ Firestore).
   - Web + không phải staff → `/login` + `staffOnlyWeb`.
   - Mobile + admin → `/login` + `adminUseWebOnly`.
   - Ngược lại → `/dashboard`.

**`DashboardScreen` (router sau đăng nhập):**

- Áp dụng lại các “cổng” web/mobile/admin như trên (kép an toàn).
- **Staff** → `AdminDashboardScreen`.
- **Student** → `StudentDashboardScreen`.

---

## 3. Cờ tính năng (Feature flags)

Nguồn: `library_settings/config` — trường `features` (merge với mặc định trong code).

| Khóa | Ảnh hưởng chính |
|------|-----------------|
| `scanEnabled` | Tab **Quét QR** trên dashboard nhân sự (mobile); tắt thì ẩn tab và điều chỉnh index. |
| `borrowReturnEnabled` | Ô lối tắt **Tạo phiếu mượn / Trả sách** trên trang chủ admin. |
| `aiRecommendationsEnabled` | Khối **gợi ý sách (FastAPI)** trên trang chủ sinh viên. |
| `statisticsEnabled` | Ô **Thống kê** trên trang chủ admin (quick task). |

*(Tab Vận hành vẫn có mục thống kê trong `AdminManageTab`; admin home chỉ ẩn tile nhanh khi flag tắt.)*

---

## 4. Xác thực (`/login`, `/register`, `/forgot-password`)

- **Đăng nhập:** email/mật khẩu và/hoặc Google Sign-In (theo `AuthService` + màn `LoginScreen`).
- **Đăng ký:** `RegisterScreen` — **không khả dụng trên web** (màn `_WebRegisterNotAllowedScreen`).
- **Quên mật khẩu:** gửi email reset Firebase.
- Sau đăng nhập thành công: điều hướng tới `/dashboard` (và các kiểm tra vai trò/nền tảng như mục 1).

---

## 5. Dashboard sinh viên (mobile)

**Cấu trúc:** `IndexedStack` + bottom bar 4 tab.

| Tab | Nội dung | Luồng chính |
|-----|----------|-------------|
| **Trang chủ** | `StudentHomeTab` | Thống kê nhanh (sách, danh mục, phiếu của tôi); lối tắt **Thư viện** → danh sách sách; **Lịch sử** → chuyển tab 3; nếu bật flag: **FastApiRecommendedBooksSection**; danh sách **mượn gần đây** (Firestore `borrow_records`). |
| **Đang mượn** | `CurrentBorrowsScreen(embedInTab: true)` | Xem phiếu đang mượn. |
| **Lịch sử** | `BorrowHistoryScreen(embedInTab: true)` | Lịch sử mượn/trả. |
| **Cài đặt** | `LibrarySettingsTab` | Theme, ngôn ngữ, thông tin tài khoản, QR của tôi, đăng xuất, xuất dữ liệu (nếu có), v.v. — xem mục 12. |

**AppBar chung:** chuông thông báo → `/notifications`; avatar → `/profile`.

---

## 6. Dashboard nhân sự — mobile (`AdminDashboardScreen`)

**Không phải web:** bottom bar động theo `scanEnabled`.

Thứ tự tab điển hình (khi quét bật):

1. **Trang chủ** — `AdminHomeTab`: thẻ thống kê realtime (sách, user, tổng phiếu, đang mượn); bấm thẻ → mở danh sách sách / quản lý user / lịch sử / đang mượn. **Lối tắt:** thêm sách, danh sách sách, tạo mượn/trả (theo flag), danh mục, user (admin), thống kê (flag).
2. **Sách** — `BookListScreen` (nhúng trong tab).
3. **Quét** — `ScanBookTab`: camera `mobile_scanner`; quét payload thư viện → tra sách / hành động liên quan mượn (theo logic tab); tắt khi tab không active hoặc có route đè (`RouteAware`).
4. **Vận hành** — `AdminManageTab`: liên kết tạo mượn, trả sách (mobile), danh mục/tác giả/thể loại/văn phòng phẩm, user & cấu hình & audit (admin), thống kê.
5. **Cài đặt** — `LibrarySettingsTab` (chỉ khi `AppUser.isStaff`).

AppBar: thông báo, profile — tương tự sinh viên.

---

## 7. Dashboard nhân sự — web (`WebStaffDashboardShell`)

Sidebar các **khu vực** (thay bottom bar):

1. **Tổng quan** — `WebStaffHomePage`: metric tồn kho (đầu sách, bản sao, còn lại, đang cho mượn).
2. **Kho sách** — `BookListScreen` (chrome shell có thể ẩn header trùng).
3. **Quầy làm việc** — `WebStaffDeskTab`: **không camera**; nhập `bookId` hoặc **ISBN** → tra cứu → liên kết chi tiết / thao tác quầy (theo UI).
4. **Vận hành** — `AdminManageTab` (trên web một số mục mượn/trả lặp được lược bớt so với mobile).
5. **Cấu hình hệ thống** (nếu staff) — `WebSystemConfigPage`: liên kết tới bật tính năng, cấu hình nghiệp vụ thư viện, route `/settings` (tab cài đặt ứng dụng).

Header: thông báo, menu tài khoản (profile, đăng xuất).

---

## 8. Sách

### 8.1 Danh sách (`/book-list`)

- Lọc/tìm kiếm theo repository/controller (Firestore).
- Chọn sách → `/book-detail` với `arguments` chứa `id` (và có thể map tạm từ quầy web).

### 8.2 Chi tiết (`/book-detail`)

- Nếu có `id`: `StreamBuilder` doc `books/{id}` — cập nhật realtime.
- Hiển thị thông tin, QR sách (nếu có), và khi bật flag AI: **`BookSimilarRecommendationsSection`** (gợi ý tương tự / FastAPI — theo widget).

### 8.3 Thêm / Sửa (`/add-book`, `/edit-book`) — `AddEditBookScreen`

- Form thủ công: ảnh bìa (picker), có tích hợp **Cloudinary** khi upload URL.
- **Chỉ chế độ thêm mới:** nhập **hàng loạt Excel** — chọn file → parse → xem lỗi dòng → commit `BookExcelImportService` lên Firestore; có nút chia sẻ/tải **mẫu Excel** localized.

### 8.4 Xóa sách

- Sau xóa: `AppRoutes.finishBookDeletionAndOpenBookList` — pop về danh sách sách và SnackBar trên navigator gốc.

---

## 9. Mượn và trả

### 9.1 Tạo phiếu mượn (`BorrowCreateScreen` — mở qua `AppRoutes.openBorrowCreate` / `pushBorrowCreate`)

- Xác định **sách** (gõ mã / ISBN / bookId, có luồng quét QR qua `QrScannerScreen` / payload `LibraryQrPayload`).
- Xác định **người mượn** (tìm theo MSSV, email, … — có thể quét QR user).
- **Hạn trả:** mặc định theo `BorrowPolicy` + đọc `library_settings/config.loanDays` (clamp trong policy); có thể chọn ngày trong khoảng cho phép.
- Submit: ghi `borrow_records`, cập nhật tồn sách — logic tập trung `BorrowReturnService` (và các chỗ gọi Firestore liên quan).

### 9.2 Trả sách (`ReturnScreen`)

- Chỉ **nhân sự** mở được qua `AppRoutes.openReturnBook` (sinh viên gọi sẽ SnackBar từ chối).
- Quy trình chọn phiếu / quét / xác nhận trả — cập nhật `borrow_records` và tồn kho.

### 9.3 Đang mượn / Lịch sử

- `CurrentBorrowsScreen`, `BorrowHistoryScreen`: có chế độ nhúng tab hoặc full route `/current-borrows`, `/borrow-history`.

### 9.4 Tab quét (nhân sự, mobile)

- `ScanBookTab`: xử lý mã QR sách; phối hợp `BorrowReturnService` và điều hướng tới tạo mượn / chi tiết tùy ngữ cảnh.

### 9.5 QR cá nhân sinh viên (`/my-qr`)

- Payload `LibraryQrPayload.userForBorrow(uid)` — phục vụ quét tại quầy khi tạo phiếu.

---

## 10. Danh mục dữ liệu phụ trợ

| Route | Màn hình | Ai thường dùng |
|-------|----------|----------------|
| `/category-manage` | `CategoryManageScreen` | Staff |
| `/author-manage` | `AuthorManageScreen` | Staff |
| `/genre-manage` | `GenreManageScreen` | Staff |
| `/stationery-manage` | `StationeryManageScreen` | Staff |

Luồng: CRUD trên Firestore collections tương ứng; form sách tham chiếu tác giả / thể loại / đảm bảo danh mục khi import.

---

## 11. Quản trị nâng cao (chủ yếu admin)

| Route | Chức năng |
|-------|-----------|
| `/user-manage` | Quản lý người dùng (`UserManageScreen`). |
| `/library-business-settings` | `LibraryBusinessSettingsScreen` — ví dụ số ngày mượn và tham số nghiệp vụ (đồng bộ `library_settings`). |
| `/system-features` | `SystemFeatureSettingsScreen` — bật/tắt các flag ở mục 3. |
| `/audit-log` | `AuditLogScreen` — xem nhật ký thao tác (`audit_log_service`). |
| `/statistics` | `StatisticsScreen` + engine thống kê nội bộ — báo cáo/tổng hợp theo dữ liệu thư viện. |

**Web:** các mục trên còn được gom lối tắt trong `WebSystemConfigPage`.

---

## 12. Cài đặt ứng dụng (`/settings` → `LibrarySettingsTab`)

- **Mobile:** theme (sáng/tối), locale, header hồ sơ, **QR của tôi**, đăng xuất; admin có thêm lối tắt tới cấu hình nghiệp vụ / audit (theo grep route trong file).
- **Web:** `_LibrarySettingsWebPanel` — bố cục phù hợp desktop.
- **Xuất dữ liệu:** `LibraryDataExportService` (khi người dùng kích hoạt trong UI).
- **Thông báo đẩy:** khởi tạo / quyền liên quan `PushNotificationService` (đăng ký FCM, foreground, v.v. — xem `main.dart`).

---

## 13. Hồ sơ và thông báo

- **`/profile` — `ProfileScreen`:** xem/sửa thông tin Firestore `users/{uid}` (bottom sheet chỉnh sửa), avatar (image picker), v.v.
- **`/notifications` — `NotificationsScreen`:** danh sách thông báo collection `notifications` (theo schema tài liệu DB).

---

## 14. Công cụ QR chung

- **`/create-qr-code` — `CreateQrCodeScreen`:** tạo QR “đa năng” (URL, text, vCard, Wi‑Fi, email), tùy chỉnh màu (đồng bộ mặc định từ `AppSettingsController`).
- **`QrScannerScreen`:** màn quét dùng chung (mượn, tra cứu, …).

---

## 15. Gợi ý AI / FastAPI

- **`FastApiRecommendationsClient`:** gọi HTTP tới backend gợi ý (cấu hình base URL trong app — xem service).
- **Trang chủ sinh viên:** `FastApiRecommendedBooksSection` (khi `aiRecommendationsEnabled`).
- **Chi tiết sách:** `BookSimilarRecommendationsSection`.
- **`/fastapi-root-example` — `FastApiRootExampleScreen`:** màn debug / ví dụ kiểm tra API (phục vụ phát triển).

---

## 16. Thông báo đẩy (tổng quan luồng kỹ thuật)

1. `main.dart`: đăng ký background handler, foreground listeners, sau frame đính kèm `attachAuthListener` theo auth.
2. Token / tin nhắn xử lý trong `PushNotificationService`.

---

## 17. Script ngoài app (tham khảo, không phải màn hình)

Các file trong `scripts/` (ví dụ `migrate_base64_images.dart`, `generate_book_import_template.dart`, `check_urls.dart`) phục vụ **vận hành / migration / kiểm tra** — chạy bằng `dart run`, không nằm trong luồng UI người dùng cuối.

---

## 18. Bảng route đặt tên (tham chiếu nhanh)

| Route | Widget |
|-------|--------|
| `/` | `AuthCheckScreen` |
| `/login` | `LoginScreen` |
| `/register` | `RegisterScreen` (web: màn chặn) |
| `/forgot-password` | `ForgotPasswordScreen` |
| `/dashboard` | `DashboardScreen` |
| `/create-qr-code` | `CreateQrCodeScreen` |
| `/admin-dashboard` | `AdminDashboardScreen` *(có thể không dùng trực tiếp nếu luôn qua `/dashboard`)* |
| `/student-dashboard` | `StudentDashboardScreen` |
| `/book-list` | `BookListScreen` |
| `/book-detail` | `BookDetailScreen` |
| `/add-book`, `/edit-book` | `AddEditBookScreen` |
| `/borrow-create` | `BorrowCreateScreen` |
| `/return-book` | `ReturnScreen` |
| `/borrow-history` | `BorrowHistoryScreen` |
| `/current-borrows` | `CurrentBorrowsScreen` |
| `/category-manage` | `CategoryManageScreen` |
| `/user-manage` | `UserManageScreen` |
| `/statistics` | `StatisticsScreen` |
| `/library-business-settings` | `LibraryBusinessSettingsScreen` |
| `/system-features` | `SystemFeatureSettingsScreen` |
| `/audit-log` | `AuditLogScreen` |
| `/author-manage` | `AuthorManageScreen` |
| `/genre-manage` | `GenreManageScreen` |
| `/stationery-manage` | `StationeryManageScreen` |
| `/profile` | `ProfileScreen` |
| `/notifications` | `NotificationsScreen` |
| `/settings` | Scaffold + `LibrarySettingsTab` |
| `/my-qr` | `MyQrScreen` |
| `/fastapi-root-example` | `FastApiRootExampleScreen` |

---

*Tài liệu được sinh để phản ánh cấu trúc mã nguồn; khi refactor route hoặc đổi tên collection, cần cập nhật song song file này.*
