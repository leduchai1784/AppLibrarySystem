# Kế hoạch Kiểm thử (Test Plan) - Hệ thống Thư viện

Tài liệu này mô tả chi tiết kế hoạch kiểm thử cho các chức năng cốt lõi: Đăng nhập, Mượn/Trả sách, và Tìm kiếm trên cả hai nền tảng Mobile (Ứng dụng di động) và Web.

> [!NOTE]
> Mục tiêu của kế hoạch kiểm thử này là đảm bảo các chức năng hoạt động chính xác, ổn định và mang lại trải nghiệm người dùng tốt trên các nền tảng khác nhau.

## 1. Chức năng Đăng nhập (Login)

### 1.1. Mobile App
*   **TC_MOB_LOG_01: Đăng nhập thành công với thông tin hợp lệ**
    *   *Bước thực hiện:* Nhập email và mật khẩu đúng của một tài khoản đã tồn tại. Nhấn "Đăng nhập".
    *   *Kết quả mong đợi:* Chuyển hướng thành công đến màn hình chính (Home) của ứng dụng. Trạng thái người dùng được lưu trữ đúng.
*   **TC_MOB_LOG_02: Đăng nhập thất bại với sai mật khẩu**
    *   *Bước thực hiện:* Nhập email đúng nhưng mật khẩu sai. Nhấn "Đăng nhập".
    *   *Kết quả mong đợi:* Hiển thị thông báo lỗi rõ ràng (VD: "Sai email hoặc mật khẩu"). Không cho phép đăng nhập.
*   **TC_MOB_LOG_03: Đăng nhập thất bại với email không tồn tại**
    *   *Bước thực hiện:* Nhập một email chưa được đăng ký trong hệ thống.
    *   *Kết quả mong đợi:* Hiển thị thông báo lỗi "Tài khoản không tồn tại".
*   **TC_MOB_LOG_04: Kiểm tra tính hợp lệ của Form (Validation)**
    *   *Bước thực hiện:* Bỏ trống email hoặc mật khẩu, hoặc nhập email sai định dạng (VD: `abc@`). Nhấn "Đăng nhập".
    *   *Kết quả mong đợi:* Hiển thị cảnh báo validation ngay tại ô nhập liệu (VD: "Vui lòng nhập email hợp lệ", "Mật khẩu không được để trống"). Nút đăng nhập có thể bị vô hiệu hóa cho đến khi nhập đúng định dạng.
*   **TC_MOB_LOG_05: Kiểm tra tính năng "Quên mật khẩu"**
    *   *Bước thực hiện:* Nhấn vào liên kết "Quên mật khẩu". Nhập email và gửi yêu cầu.
    *   *Kết quả mong đợi:* Hệ thống gửi email khôi phục mật khẩu. Xác nhận quy trình đặt lại mật khẩu thành công.

### 1.2. Web App
*   **TC_WEB_LOG_01 -> TC_WEB_LOG_05:** Tương tự như Mobile App.
*   **TC_WEB_LOG_06: Kiểm tra phiên đăng nhập (Session Management)**
    *   *Bước thực hiện:* Đăng nhập thành công, mở một tab mới và truy cập lại trang web.
    *   *Kết quả mong đợi:* Hệ thống tự động nhận diện phiên đăng nhập mà không cần bắt đăng nhập lại.
*   **TC_WEB_LOG_07: Đăng xuất (Logout)**
    *   *Bước thực hiện:* Đang ở trạng thái đăng nhập, nhấn "Đăng xuất", sau đó nhấn nút "Back" của trình duyệt.
    *   *Kết quả mong đợi:* Chuyển về trang đăng nhập. Không thể truy cập các trang yêu cầu quyền đăng nhập bằng nút Back.

---

## 2. Chức năng Mượn/Trả sách

> [!IMPORTANT]
> Hệ thống **không có luồng “yêu cầu mượn → chờ duyệt”**. Phiếu mượn được tạo **ngay** với `status = borrowing`. Trả sách do **nhân sự** (admin/manager) xử lý; sinh viên **không** tự trả trên app.
>
> Kiểm thử cần đối chiếu Firestore: `borrow_records`, `books.availableQuantity`, `users.totalBorrowed`, `library_settings/config` (`loanDays`, `finePerDay`, `maxActiveBorrowsPerUser`), feature flag `borrowReturnEnabled`.

### 2.0. Tổng quan luồng (theo code hiện tại)

| Vai trò | Nền tảng | Mượn sách | Trả sách | Xem phiếu |
|--------|----------|-----------|----------|-----------|
| **Sinh viên** | App mobile | Tab **Quét** → quét QR sách → **Mượn cho tôi** (`BorrowReturnService.borrowBook`) | Không (chỉ nhân sự) | Tab **Đang mượn** / **Lịch sử** |
| **Manager / Admin** | App mobile | **Tạo phiếu mượn** (`BorrowCreateScreen`) hoặc quét `LIB_USER:` / sách | **Trả sách** (`ReturnScreen`), quét `LIB_RET:{id}` | **Đang mượn** (toàn hệ thống), **Lịch sử** |
| **Manager / Admin** | Web | **Quầy làm việc** / Tổng quan → **Tạo phiếu** (không camera; nhập bookId/ISBN) | **Trả sách** (cùng màn `ReturnScreen`) | Kho sách + màn mượn/trả như mobile |
| **Admin** | Web / App | + **Thanh toán phạt** (`FinePaymentScreen`) | — | — |

**QR nội bộ (`LibraryQrPayload`):**

- `LIB_RET:{borrowRecordId}` — in trên phiếu sau khi tạo mượn; quét → mở trả với phiếu đã điền.
- `LIB_USER:{firebaseUid}` — QR **Mã của tôi**; nhân sự quét → tạo phiếu với SV đã chọn.
- QR sách: `bookId` hoặc **ISBN** (không prefix).

**Trạng thái phiếu:** `borrowing` → khi trả đúng hạn: `returned`; trễ hạn: `late` + `fineAmount` (ngày trễ × `finePerDay`).

---

### 2.1. App mobile — Sinh viên

#### Luồng mượn (tab Quét)

1. Đăng nhập app (email đã xác thực).
2. Dashboard → tab **Quét** (cần `scanEnabled` và `borrowReturnEnabled` nếu kiểm tra flag).
3. Quét QR sách (bookId/ISBN).
4. Bottom sheet → chọn **Mượn cho tôi**.
5. Hệ thống gọi `BorrowReturnService.borrowBook` (hạn mượn từ `library_settings/config.loanDays`, clamp 3–30 ngày).

*Kết quả Firestore:* tạo `borrow_records` (`status: borrowing`, `fineAmount: 0`); giảm `books.availableQuantity`; tăng `users.totalBorrowed`; có thể thêm `notifications` cho SV.

*Lưu ý:* Chi tiết sách **không** có nút “Tạo phiếu” cho sinh viên — chỉ nhân sự.

#### Luồng xem / không được trả

- Tab **Đang mượn** / **Lịch sử**: chỉ xem, không nút trả.
- Quét `LIB_RET:...` → SnackBar từ chối (chỉ nhân sự được trả).
- Quét `LIB_USER:...` → từ chối (QR SV dành cho thủ thư).

#### Test case — Sinh viên

*   **TC_MOB_STU_BOR_01: Mượn sách qua quét QR thành công**
    *   *Điều kiện:* Sách `availableQuantity > 0`; SV `isActive = true`; chưa mượn cùng đầu sách; chưa đạt `maxActiveBorrowsPerUser`.
    *   *Bước:* Tab Quét → quét QR sách → **Mượn cho tôi**.
    *   *Kỳ vọng:* SnackBar thành công; phiếu `borrowing`; tồn kho giảm 1; tab Đang mượn có phiếu mới.
*   **TC_MOB_STU_BOR_02: Mượn thất bại — hết sách**
    *   *Điều kiện:* `availableQuantity = 0`.
    *   *Kỳ vọng:* Lỗi `out_of_stock` / thông báo tương ứng; không tạo phiếu.
*   **TC_MOB_STU_BOR_03: Mượn thất bại — đã mượn cùng sách**
    *   *Kỳ vọng:* Lỗi `already_borrowing`.
*   **TC_MOB_STU_BOR_04: Mượn thất bại — vượt số phiếu đang mượn tối đa**
    *   *Kỳ vọng:* Lỗi `max_active_borrows`.
*   **TC_MOB_STU_RET_01: Sinh viên không trả được qua app**
    *   *Bước:* Quét `LIB_RET:...` hoặc cố mở `ReturnScreen`.
    *   *Kỳ vọng:* Bị chặn / không có quyền trả.

---

### 2.2. App mobile — Nhân sự (Manager / Admin)

#### Luồng tạo phiếu (`BorrowCreateScreen`)

1. Vào màn từ: Trang chủ (lối tắt) / Tab Vận hành / Chi tiết sách (staff) / Quét (`LIB_USER:` hoặc sách → **Tạo phiếu cho SV**).
2. **Bước 1 — Sách:** nhập hoặc quét bookId/ISBN → tra cứu.
3. **Bước 2 — Sinh viên:** nhập MSSV/email hoặc quét `LIB_USER:`.
4. Chọn **hạn trả** (DatePicker, trong khoảng 3–30 ngày; mặc định gợi ý từ `loanDays`).
5. **Tạo phiếu mượn**.

*Kỳ vọng:* Dialog thành công + **QR `LIB_RET:{id}`** để in/dán phiếu; `processedBy` = UID nhân sự; thông báo cho SV.

#### Luồng trả (`ReturnScreen` — chỉ staff)

1. Mở **Trả sách** (lối tắt / tab Quét quét `LIB_RET:` / Đang mượn → trả theo phiếu).
2. Nhập mã phiếu, quét QR phiếu, hoặc **Tìm** — chỉ phiếu `status = borrowing`.
3. **Xác nhận trả**.

*Kỳ vọng:* `returnDate` set; `status` = `returned` hoặc `late`; `fineAmount` nếu trễ; `availableQuantity` +1; thông báo cho SV.

#### Thanh toán phạt (Admin / Manager)

- Màn **Thanh toán phạt** (`FinePaymentScreen`): danh phiếu trễ có `fineAmount > 0`, chưa `finePaid` → **Thu phạt**.

#### Test case — Nhân sự mobile

*   **TC_MOB_STF_BOR_01: Tạo phiếu đủ sách + SV + hạn trả**
    *   *Bước:* `BorrowCreateScreen` → điền sách, SV, hạn trả hợp lệ → Tạo.
    *   *Kỳ vọng:* Phiếu `borrowing`; QR `LIB_RET:` hiển thị; tồn kho giảm.
*   **TC_MOB_STF_BOR_02: Quét `LIB_USER:` mở form với SV sẵn**
    *   *Kỳ vọng:* Ô SV đã điền; chỉ cần chọn sách và tạo.
*   **TC_MOB_STF_BOR_03: Tạo thất bại — SV bị khóa (`isActive = false`)**
    *   *Kỳ vọng:* SnackBar không cho mượn.
*   **TC_MOB_STF_RET_01: Trả đúng hạn qua quét `LIB_RET:`**
    *   *Bước:* Quét QR phiếu → Xác nhận trả (trước `dueDate`).
    *   *Kỳ vọng:* `status = returned`, `fineAmount = 0`.
*   **TC_MOB_STF_RET_02: Trả trễ hạn — có phạt**
    *   *Điều kiện:* `finePerDay > 0` trong config.
    *   *Kỳ vọng:* `status = late`, `fineAmount = số_ngày_trễ × finePerDay`.
*   **TC_MOB_STF_RET_03: Trả phiếu không còn `borrowing`**
    *   *Kỳ vọng:* Thông báo phiếu không hợp lệ / không active.
*   **TC_MOB_STF_FINE_01: Ghi nhận thu phạt**
    *   *Bước:* `FinePaymentScreen` → Thu phạt → xác nhận.
    *   *Kỳ vọng:* Phiếu đánh dấu đã thu (`finePaid`); biến mất khỏi danh sách chưa thu.

---

### 2.3. Web — Nhân sự (Admin / Manager)

> Sinh viên **không** dùng web (bị chặn sau đăng nhập). Admin **chỉ web**; manager dùng web + app.

#### Khác biệt so với app

| Hạng mục | Web | App mobile |
|----------|-----|------------|
| Quét camera | **Không** — tab **Quầy làm việc**: nhập bookId/ISBN | Tab **Quét** + `QrScannerScreen` |
| Tạo phiếu | Tổng quan / Quầy / Kết quả tra sách → **Tạo phiếu** | + quét `LIB_USER:` / sách |
| Trả sách | Cùng `ReturnScreen` (nhập/quét phiếu) | + quét `LIB_RET:` từ tab Quét |
| Tab Vận hành | Có danh mục, user, thống kê; **không** lặp lối tắt mượn/trả ở mobile | Có Tạo/Trả ở tab Vận hành |

#### Luồng web — Quầy làm việc

1. Sidebar → **Quầy làm việc** (`WebStaffDeskTab`).
2. Nhập **bookId** hoặc **ISBN** → **Tìm**.
3. Thẻ sách → **Chi tiết** hoặc **Tạo phiếu mượn** (prefill `bookId`).
4. Hoàn tất `BorrowCreateScreen` như mobile (sách + SV + hạn trả).

#### Luồng web — Trả & phạt

- **Tổng quan** hoặc lối tắt → **Trả sách** / **Thanh toán phạt** (admin).
- `ReturnScreen`: không tự tra khi mở màn — thủ thư phải **Tìm** hoặc quét QR phiếu.

#### Test case — Web

*   **TC_WEB_STF_BOR_01: Tra cứu sách tại quầy (bookId)**
    *   *Bước:* Quầy làm việc → nhập bookId → Tìm.
    *   *Kỳ vọng:* Hiện thẻ sách; nút Tạo phiếu mở form với sách đã chọn.
*   **TC_WEB_STF_BOR_02: Tra cứu theo ISBN**
    *   *Kỳ vọng:* Tìm được khi ISBN khớp Firestore.
*   **TC_WEB_STF_BOR_03: Tạo phiếu hoàn chỉnh trên web**
    *   *Kỳ vọng:* Giống TC_MOB_STF_BOR_01; QR trả hiển thị sau tạo.
*   **TC_WEB_STF_RET_01: Trả sách nhập mã phiếu**
    *   *Bước:* Trả sách → nhập id `borrow_records` → Tìm → Xác nhận.
    *   *Kỳ vọng:* Cập nhật Firestore như mobile.
*   **TC_WEB_STF_FINE_01: Thu phạt trên web**
    *   *Kỳ vọng:* Giống TC_MOB_STF_FINE_01.
*   **TC_WEB_STF_FLAG_01: Tắt `borrowReturnEnabled`**
    *   *Bước:* Admin → Cấu hình tính năng → tắt mượn/trả.
    *   *Kỳ vọng:* Lối tắt Tạo/Trả trên Trang chủ mobile ẩn (theo `FeatureFlagsService`).

---

### 2.4. Kiểm tra dữ liệu Firestore (chung)

*   **TC_BOR_DB_01:** Sau mượn — `availableQuantity` giảm đúng 1; `borrow_records.status = borrowing`.
*   **TC_BOR_DB_02:** Sau trả — `availableQuantity` tăng 1; `returnDate` có giá trị; `status` ∈ {`returned`, `late`}.
*   **TC_BOR_DB_03:** Không tạo hai phiếu `borrowing` cho cùng `userId` + `bookId`.
*   **TC_BOR_DB_04:** Thông báo in-app (`notifications`) sau mượn/trả khi user bật `notifyBorrowReminders`.

---

## 3. Chức năng Tìm kiếm (Search)

### 3.1. Mobile App
*   **TC_MOB_SRC_01: Tìm kiếm theo Tên sách (Chính xác)**
    *   *Bước thực hiện:* Nhập chính xác tên một cuốn sách đang có trong hệ thống vào thanh tìm kiếm.
    *   *Kết quả mong đợi:* Hiển thị đúng cuốn sách đó ở kết quả đầu tiên.
*   **TC_MOB_SRC_02: Tìm kiếm theo Tên sách (Tương đối/Một phần)**
    *   *Bước thực hiện:* Nhập một vài từ khóa hoặc tên một phần của cuốn sách.
    *   *Kết quả mong đợi:* Hiển thị danh sách các cuốn sách có tên chứa từ khóa tìm kiếm.
*   **TC_MOB_SRC_03: Tìm kiếm theo Tác giả hoặc Thể loại**
    *   *Bước thực hiện:* Sử dụng bộ lọc (Filter) hoặc nhập tên tác giả.
    *   *Kết quả mong đợi:* Hiển thị danh sách các cuốn sách thuộc tác giả hoặc thể loại tương ứng.
*   **TC_MOB_SRC_04: Tìm kiếm không có kết quả**
    *   *Bước thực hiện:* Nhập một chuỗi ký tự không có ý nghĩa (VD: "xyz123abc").
    *   *Kết quả mong đợi:* Hiển thị thông báo "Không tìm thấy kết quả phù hợp" kèm theo thiết kế UI (Empty State) thân thiện.
*   **TC_MOB_SRC_05: Hiệu suất tìm kiếm (Performance)**
    *   *Bước thực hiện:* Gõ nhanh trên thanh tìm kiếm (Debounce test).
    *   *Kết quả mong đợi:* UI không bị giật lag. Ứng dụng chỉ gọi API tìm kiếm sau khi người dùng ngừng gõ một khoảng thời gian ngắn (debouncing) để tiết kiệm tài nguyên.

### 3.2. Web App
*   **TC_WEB_SRC_01 -> TC_WEB_SRC_04:** Tương tự như Mobile App.
*   **TC_WEB_SRC_05: Tìm kiếm nâng cao (Dành cho Admin)**
    *   *Bước thực hiện:* Tìm kiếm kết hợp nhiều tiêu chí: Tên sách + Mã ISBN + Trạng thái (Còn sách/Hết sách).
    *   *Kết quả mong đợi:* Bảng dữ liệu lọc chính xác các kết quả thỏa mãn tất cả các tiêu chí.
*   **TC_WEB_SRC_06: Tìm kiếm người dùng (Dành cho Admin)**
    *   *Bước thực hiện:* Tìm kiếm người dùng bằng email, tên hoặc số điện thoại.
    *   *Kết quả mong đợi:* Hiển thị đúng thông tin hồ sơ của người dùng để tiến hành các thao tác quản trị.
