# Cơ sở dữ liệu - Library System

Tài liệu mô tả cấu trúc Firestore cho ứng dụng quản lý thư viện QR.

---

## Tổng quan

| Collection      | Mô tả                          |
|-----------------|--------------------------------|
| `users`         | Thông tin sinh viên & admin    |
| `authors`       | Tác giả sách                  |
| `categories`    | Danh mục phân loại sách       |
| `genres`        | Thể loại sách                 |
| `books`         | Thông tin sách                |
| `borrow_records`| Lịch sử mượn trả              |
| `notifications` | Thông báo (optional)          |
| `statistics`    | Cache thống kê (optional)     |
| `library_settings` | Cấu hình thư viện (optional) |

---

## 1. Collection: `users`

Lưu thông tin người dùng (sinh viên & admin).

| Field          | Type      | Mô tả                         |
|----------------|-----------|-------------------------------|
| `uid`          | string    | Firebase Auth UID             |
| `fullName`     | string    | Họ tên                        |
| `email`        | string    | Email đăng nhập               |
| `role`         | string    | `"admin"` \| `"student"`      |
| `studentCode`  | string    | MSSV (nếu là sinh viên)       |
| `phone`        | string    | Số điện thoại                 |
| `avatarUrl`    | string    | URL ảnh đại diện (optional)   |
| `createdAt`    | timestamp | Ngày tạo tài khoản            |
| `isActive`     | boolean   | Trạng thái tài khoản          |
| `totalBorrowed`| number    | Tổng số lần đã mượn           |

**Cấu trúc:** `users/{userId}`

---

## 2. Collection: `categories`

Phân loại sách theo danh mục.

| Field         | Type      | Mô tả           |
|---------------|-----------|-----------------|
| `name`        | string    | Tên danh mục    |
| `description` | string    | Mô tả           |
| `createdAt`   | timestamp | Ngày tạo        |

**Cấu trúc:** `categories/{categoryId}`

---

## 3. Collection: `authors`

Tác giả sách.

| Field         | Type      | Mô tả               |
|---------------|-----------|---------------------|
| `name`        | string    | Tên tác giả         |
| `description` | string    | Tiểu sử (optional)  |
| `imageUrl`    | string    | Ảnh tác giả (optional) |
| `createdAt`   | timestamp | Ngày tạo            |
| `updatedAt`   | timestamp | Ngày cập nhật (optional) |

**Cấu trúc:** `authors/{authorId}`

---

## 4. Collection: `genres`

Thể loại sách (phân loại chi tiết theo nội dung).

| Field         | Type      | Mô tả           |
|---------------|-----------|-----------------|
| `name`        | string    | Tên thể loại    |
| `description` | string    | Mô tả           |
| `createdAt`   | timestamp | Ngày tạo        |
| `updatedAt`   | timestamp | Ngày cập nhật (optional) |

**Cấu trúc:** `genres/{genreId}`

---

## 5. Collection: `books`

Thông tin sách trong kho.

| Field              | Type      | Mô tả                   |
|--------------------|-----------|-------------------------|
| `title`            | string    | Tên sách                |
| `author`           | string    | Tên tác giả (denormalized, để tìm kiếm) |
| `authorId`         | string    | ID tác giả (FK → authors, optional) |
| `categoryId`       | string    | ID danh mục (FK → categories) |
| `genreId`          | string    | ID thể loại (FK → genres, optional) |
| `description`      | string    | Mô tả                   |
| `isbn`             | string    | Mã ISBN (tìm kiếm, QR)  |
| `publishedYear`    | number    | Năm xuất bản            |
| `quantity`         | number    | Tổng số lượng           |
| `availableQuantity`| number    | Số còn lại              |
| `imageUrl`         | string    | URL ảnh bìa             |
| `isAvailable`      | boolean   | Còn sách không          |
| `createdAt`        | timestamp | Ngày thêm               |
| `updatedAt`        | timestamp | Ngày cập nhật (optional)|
| `totalBorrowCount` | number    | Tổng lượt mượn (thống kê)|

**Cấu trúc:** `books/{bookId}`

---

## 6. Collection: `borrow_records`

Lịch sử mượn trả sách.

| Field        | Type      | Mô tả                                  |
|--------------|-----------|----------------------------------------|
| `userId`     | string    | ID người mượn                          |
| `bookId`     | string    | ID sách                                |
| `borrowDate` | timestamp | Ngày mượn                              |
| `dueDate`    | timestamp | Hạn trả                                |
| `returnDate` | timestamp | Ngày trả (null nếu chưa trả)           |
| `status`     | string    | `"borrowing"` \| `"returned"` \| `"late"` |
| `fineAmount` | number    | Tiền phạt (trả muộn)                   |
| `processedBy`| string    | UID admin xử lý mượn/trả               |

**Cấu trúc:** `borrow_records/{borrowId}`

---

## 7. Collection: `notifications` (Optional)

Thông báo cho người dùng (ví dụ: sắp đến hạn trả).

| Field       | Type      | Mô tả               |
|-------------|-----------|---------------------|
| `userId`    | string    | ID người nhận       |
| `message`   | string    | Nội dung            |
| `createdAt` | timestamp | Thời gian tạo       |
| `isRead`    | boolean   | Đã đọc chưa         |
| `type`      | string    | `"due_reminder"` \| `"overdue"` \| `"system"` (optional) |

**Cấu trúc:** `notifications/{notificationId}`

---

## 8. Collection: `statistics` (Optional Cache)

Cache thống kê để tối ưu hiệu năng dashboard.

| Field              | Type   | Mô tả                    |
|--------------------|--------|--------------------------|
| `totalBooks`       | number | Tổng số sách             |
| `totalUsers`       | number | Tổng số người dùng       |
| `totalBorrowed`    | number | Tổng lượt đang mượn      |
| `mostBorrowedBookId`| string| ID sách mượn nhiều nhất  |
| `lastUpdated`      | timestamp | Thời gian cập nhật (optional) |

**Cấu trúc:** `statistics/dashboard` (1 document cố định)

---

## 9. Collection: `library_settings` (Optional)

Cấu hình thư viện (một document duy nhất).

| Field        | Type   | Mô tả                    |
|--------------|--------|--------------------------|
| `libraryName`| string | Tên thư viện             |
| `loanDays`   | number | Số ngày mượn mặc định    |
| `finePerDay` | number | Phạt mỗi ngày trả muộn   |
| `updatedAt`  | timestamp | Thời điểm cập nhật    |

**Cấu trúc:** `library_settings/config`

---

## Quan hệ giữa các Collection

```
User (1) ----< (N) BorrowRecord (N) >---- (1) Book
Category (1) ----< (N) Book
Genre (1) ----< (N) Book
Author (1) ----< (N) Book
Admin (User) (1) ----< (N) BorrowRecord [processedBy]
```

- **User ↔ BorrowRecord:** Một user có nhiều borrow record
- **Book ↔ BorrowRecord:** Một sách có nhiều lượt mượn
- **Category ↔ Book:** Một danh mục có nhiều sách
- **Genre ↔ Book:** Một thể loại có nhiều sách
- **Author ↔ Book:** Một tác giả có nhiều sách
- **Admin ↔ BorrowRecord:** Một admin xử lý nhiều phiếu mượn/trả

---

## Chức năng ứng dụng & dữ liệu tương ứng

| Chức năng         | Collection(s) dùng           |
|-------------------|-----------------------------|
| Đăng nhập         | `users`                     |
| Phân quyền        | `users.role`                |
| CRUD sách         | `books`, `categories`, `authors`, `genres` |
| Quét QR mượn sách | `books`, `borrow_records`   |
| Trả sách          | `borrow_records`            |
| Phạt trả muộn     | `borrow_records.fineAmount` |
| Thống kê          | `books`, `statistics`       |
| Lịch sử mượn      | `borrow_records`            |
| Tìm sách          | `books`, `categories`, `authors`, `genres` |
| Thông báo         | `notifications`             |
| Cài đặt thư viện  | `library_settings`          |
