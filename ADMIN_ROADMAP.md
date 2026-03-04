## Lộ trình phát triển chức năng trang Admin - Library System

Tài liệu này mô tả lộ trình phát triển các chức năng dành cho **Admin** trong ứng dụng quản lý thư viện QR.

Lộ trình chia làm 3 giai đoạn chính, ưu tiên xây dựng **chức năng core** trước, sau đó mở rộng dữ liệu sách và cuối cùng là các tính năng quản trị, thống kê, tối ưu trải nghiệm.

---

## Giai đoạn 1 – Chức năng core (bắt buộc phải có)

### 1. Quản lý sách (Books)

- **Xem danh sách sách**
  - Màn hình: `BookListScreen`.
  - Hiển thị: tên sách, tác giả, danh mục, thể loại, trạng thái còn/het, số lượng.
  - Tìm kiếm theo tên sách, mã ISBN.

- **Thêm / sửa / xóa sách**
  - Màn hình: `AddEditBookScreen`.
  - Trường thông tin chính: `title`, `author`, `authorId`, `categoryId`, `genreId`, `isbn`, `publishedYear`, `quantity`, `imageUrl`, `description`.
  - Cho phép admin:
    - Thêm sách mới.
    - Chỉnh sửa thông tin sách.
    - Ẩn/xóa sách (có thể dùng cờ `isAvailable` để soft delete).

- **Xem chi tiết sách**
  - Màn hình: `BookDetailScreen`.
  - Hiển thị đầy đủ thông tin sách + lịch sử mượn cơ bản (nếu cần).

### 2. Quản lý người dùng (Users)

- **Danh sách người dùng**
  - Màn hình: `UserManageScreen`.
  - Hiển thị: họ tên, email, role, trạng thái `isActive`, tổng số lần mượn.
  - Lọc theo role: admin / student.

- **Khóa / mở khóa tài khoản**
  - Thay đổi field `isActive` trong collection `users`.
  - Nếu `isActive = false` → chặn đăng nhập vào hệ thống.

- **(Tuỳ chọn) Thay đổi role**
  - Chuyển `role` giữa `student` và `admin` (chỉ cho super admin).

### 3. Quản lý mượn – trả (Borrow records)

- **Tạo phiếu mượn**
  - Màn hình: `BorrowCreateScreen`.
  - Chọn user + chọn sách (có thể hỗ trợ quét QR từ `ScanBookTab`).
  - Ghi vào collection `borrow_records` với các trường: `userId`, `bookId`, `borrowDate`, `dueDate`, `status`.
  - Cập nhật `availableQuantity` và `totalBorrowCount` của sách.

- **Trả sách**
  - Màn hình: `ReturnScreen`.
  - Cập nhật `returnDate`, `status`, `fineAmount` (nếu trễ hạn).
  - Tăng lại `availableQuantity` của sách.

- **Lịch sử mượn**
  - Màn hình: `BorrowHistoryScreen`.
  - Xem lịch sử mượn theo người dùng, theo sách, theo thời gian.

- **Danh sách đang mượn hiện tại**
  - Màn hình: `CurrentBorrowsScreen`.
  - Liệt kê các bản ghi `borrow_records` có `status = borrowing`.

- **Tính và hiển thị tiền phạt**
  - Màn hình: `FineScreen`.
  - Công thức: dựa trên số ngày trễ và `finePerDay` từ `library_settings`.

> Sau khi hoàn thành Giai đoạn 1, admin đã có thể: **quản lý sách, quản lý user, thực hiện mượn - trả và xử lý phạt**.

---

## Giai đoạn 2 – Mở rộng dữ liệu sách (Authors, Categories, Genres)

### 4. Quản lý danh mục (Categories)

- Màn hình: `CategoryManageScreen`.
- Chức năng:
  - Thêm / sửa / xóa danh mục trong collection `categories`.
  - Gán `categoryId` cho sách trong `AddEditBookScreen`.

### 5. Quản lý thể loại (Genres)

- Màn hình (mới): quản lý thể loại dựa trên collection `genres`.
- Chức năng:
  - Thêm / sửa / xóa thể loại.
  - Gán `genreId` cho sách.

### 6. Quản lý tác giả (Authors)

- Màn hình (mới): quản lý tác giả dựa trên collection `authors`.
- Chức năng:
  - Thêm / sửa / xóa tác giả (tên, mô tả, ảnh).
  - Gán `authorId` cho sách, đồng thời lưu `author` (tên) để tìm kiếm nhanh.

> Sau Giai đoạn 2, dữ liệu sách sẽ được chuẩn hóa hơn, dễ lọc/tìm kiếm theo tác giả, danh mục, thể loại.

---

## Giai đoạn 3 – Quản trị, thống kê & tối ưu trải nghiệm

### 7. Cài đặt thư viện (Library settings)

- Màn hình: `LibrarySettingsTab`.
- Dùng document `library_settings/config` để lưu:
  - `libraryName`: tên thư viện.
  - `loanDays`: số ngày mượn mặc định.
  - `finePerDay`: tiền phạt mỗi ngày trễ.
  - (Tuỳ chọn) giới hạn số sách được mượn cùng lúc.

- Ứng dụng:
  - Dùng `loanDays` khi tạo phiếu mượn (`dueDate = borrowDate + loanDays`).
  - Dùng `finePerDay` khi tính phạt trong `FineScreen`.

### 8. Thống kê & báo cáo (Statistics)

- Màn hình: `StatisticsScreen`.
- Chỉ số chính:
  - Tổng số sách (`totalBooks`).
  - Tổng số user (`totalUsers`).
  - Số lượt mượn đang active (`totalBorrowed`).
  - Sách mượn nhiều nhất (`mostBorrowedBookId`).

- Tối ưu hiệu năng:
  - Dùng collection `statistics` để cache kết quả thống kê, cập nhật định kỳ hoặc theo sự kiện.

### 9. Thông báo & nhắc nhở (Notifications)

- Màn hình: `NotificationsScreen` (admin view + user view).
- Chức năng cho admin:
  - Gửi thông báo hệ thống (broadcast) cho nhiều user.
  - Tạo notification cho user khi:
    - Sắp đến hạn trả.
    - Đã quá hạn trả.

- Dữ liệu:
  - Dùng collection `notifications` với các field `userId`, `message`, `type`, `isRead`, `createdAt`.

> Giai đoạn 3 giúp admin **quản trị hệ thống dễ hơn**, có số liệu tổng quan và giúp người dùng nhận được nhắc nhở kịp thời.

---

## Gợi ý thứ tự triển khai

1. Hoàn thiện **Giai đoạn 1** (Books + Users + Borrow/Return/Fine).
2. Bổ sung **Giai đoạn 2** (Categories, Genres, Authors) và gắn vào form sách.
3. Xây dựng **Giai đoạn 3** (Settings, Statistics, Notifications) để hoàn thiện trải nghiệm quản trị.

Tùy yêu cầu đồ án/báo cáo, bạn có thể dừng sau Giai đoạn 1–2 (core) hoặc triển khai thêm một phần của Giai đoạn 3 (ví dụ: cài đặt thư viện + thống kê cơ bản).

