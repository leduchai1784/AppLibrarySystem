# Firestore Security Rules

File: `firestore.rules`

## Thay đổi so với rules mặc định (deny all)

| Trước | Sau |
|-------|-----|
| `allow read, write: if false` (chặn mọi thao tác) | Phân quyền theo collection và vai trò |

## Quy tắc theo collection

| Collection | Đọc | Ghi |
|------------|-----|-----|
| **users** | User đọc chính mình; Admin đọc tất cả | User tạo/sửa chính mình; Admin sửa/xóa |
| **categories** | Tất cả user đã đăng nhập | Chỉ Admin |
| **books** | Tất cả user đã đăng nhập | Chỉ Admin |
| **borrow_records** | User đọc của mình; Admin đọc tất cả | User tạo; Admin sửa/xóa |
| **notifications** | User đọc của mình; Admin đọc tất cả | User tạo; Admin sửa/xóa |
| **statistics** | Tất cả user đã đăng nhập | Chỉ Admin |
| **library_settings** | Tất cả user đã đăng nhập | Chỉ Admin |

## Triển khai lên Firebase

```bash
firebase deploy --only firestore:rules
```

> Lưu ý: Cần cấu hình project Firebase trước (`firebase use <project-id>` hoặc `firebase init`).

## Liên quan

- `firebase.json`: thêm `"firestore": { "rules": "firestore.rules" }` nếu dùng `firebase init firestore`
- Firebase Console → Firestore → Rules: có thể copy nội dung `firestore.rules` dán trực tiếp để cập nhật
