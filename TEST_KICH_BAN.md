# Kịch bản kiểm thử API — AI Library System

Tài liệu này mô tả **6 test tự động (pytest)** hiện có trong project và cách chạy.  
Đây là test **đơn vị/tích hợp API** dùng **mock** (không gọi Firestore/ML thật).

---

## 1. Tổng quan: “6 pass” là gì?

Khi chạy:

```powershell
cd C:\HK_II_4\DACN\ai-library-system
python -m pytest tests/ -v
```

Kết quả chuẩn:

```text
6 passed
```

| # | Tên test | Endpoint | Kỳ vọng HTTP |
|---|----------|----------|--------------|
| 1 | `test_recommend_success` | `GET /recommend?book_id=book_1&top_k=5` | **200** |
| 2 | `test_recommend_book_not_found` | `GET /recommend?book_id=invalid_book` | **404** |
| 3 | `test_recommend_me_success_dev_auth` | `GET /recommend/me` + header `X-Dev-Uid` | **200** |
| 4 | `test_recommend_me_success_bearer_auth` | `GET /recommend/me` + `Authorization: Bearer ...` | **200** |
| 5 | `test_recommend_me_missing_auth` | `GET /recommend/me` (không header) | **401** |
| 6 | `test_recommend_me_firebase_inactive` | `GET /recommend/me` khi Firebase tắt | **503** |

**Lưu ý:** 6 test này **không** bao gồm test thủ công `GET /` hay `GET /health`. Hai endpoint đó vẫn có trên server nhưng chưa có testcase pytest riêng.

---

## 2. Chuẩn bị môi trường test

### 2.1 Cài dependency test

```powershell
cd C:\HK_II_4\DACN\ai-library-system
.\.venv\Scripts\activate
python -m pip install -r requirements.txt
python -m pip install -r requirements-test.txt
```

### 2.2 Chạy toàn bộ test

```powershell
python -m pytest tests/ -v
```

### 2.3 Báo cáo HTML (tự sinh theo `pytest.ini`)

Sau khi chạy, mở file:

`reports/report.html`

Báo cáo HTML đã được tùy chỉnh (trong `tests/conftest.py`):

- Tiêu đề tiếng Việt: **Báo cáo kiểm thử API — Hệ thống thư viện AI**
- Cột **Mô tả nghiệp vụ** (giải thích từng testcase bằng tiếng Việt)
- Kết quả hiển thị **Đạt / Không đạt** thay vì Passed/Failed

---

## 3. Cơ chế mock (tại sao test chạy nhanh, không cần Firebase)

File `tests/conftest.py` mock:

- **`get_recommender()`** → trả sách giả, không load TF‑IDF/SVD thật.
- **`get_firebase_service()`** → không kết nối Firestore.
- **Firebase Auth** → `verify_firebase_id_token` luôn trả `uid = test_uid`.

Vì vậy 6 test chỉ kiểm tra **logic route + status code + gọi đúng service**, không kiểm tra chất lượng gợi ý ML trên dữ liệu thật.

---

## 4. Kịch bản chi tiết từng testcase

### TC-01 — Gợi ý theo sách thành công

| Mục | Nội dung |
|-----|----------|
| **Mục tiêu** | Xác nhận `GET /recommend` trả danh sách sách khi `book_id` hợp lệ |
| **Điều kiện** | `get_book("book_1")` trả về sách; `recommend()` trả 2 cuốn |
| **Request** | `GET /recommend?book_id=book_1&top_k=5` |
| **Kỳ vọng** | Status **200**; body là list; phần tử đầu có `id = book_2` |
| **Kiểm tra phụ** | `get_book` và `recommend(book_id="book_1", top_k=5)` được gọi đúng 1 lần |

---

### TC-02 — Không tìm thấy sách

| Mục | Nội dung |
|-----|----------|
| **Mục tiêu** | API trả lỗi khi `book_id` không tồn tại |
| **Điều kiện** | `get_book("invalid_book")` trả `None` |
| **Request** | `GET /recommend?book_id=invalid_book` |
| **Kỳ vọng** | Status **404**; `detail = "Book not found"` |

---

### TC-03 — Gợi ý cá nhân (dev bypass)

| Mục | Nội dung |
|-----|----------|
| **Mục tiêu** | `GET /recommend/me` hoạt động khi bật `DEV_AUTH_BYPASS` và gửi `X-Dev-Uid` |
| **Điều kiện** | `settings.dev_auth_bypass = True` (patch trong test) |
| **Request** | `GET /recommend/me?top_k=5` + header `X-Dev-Uid: dev_user_1` |
| **Kỳ vọng** | Status **200**; list 2 sách; sách đầu `id = book_4` |
| **Kiểm tra phụ** | `get_user_history("dev_user_1", limit=200)` được gọi |
| **Logic loại trừ** | Sách đang mượn (`history_book_2`, status `borrowing`, `returnDate = null`) nằm trong `exclude_book_ids`; sách đã trả không bị loại |

---

### TC-04 — Gợi ý cá nhân (Bearer token)

| Mục | Nội dung |
|-----|----------|
| **Mục tiêu** | Xác thực qua `Authorization: Bearer <token>` |
| **Request** | `GET /recommend/me?top_k=5` + `Authorization: Bearer some_token` |
| **Kỳ vọng** | Status **200** |
| **Kiểm tra phụ** | `get_user_history("test_uid", limit=200)` — uid từ mock token |

---

### TC-05 — Thiếu xác thực

| Mục | Nội dung |
|-----|----------|
| **Mục tiêu** | Từ chối request không có token/header dev |
| **Request** | `GET /recommend/me?top_k=5` (không header) |
| **Kỳ vọng** | Status **401**; message chứa `"Missing Authorization"` |

---

### TC-06 — Firebase không khả dụng

| Mục | Nội dung |
|-----|----------|
| **Mục tiêu** | Báo lỗi dịch vụ khi Firebase inactive |
| **Điều kiện** | `firebase.active = False` |
| **Request** | `GET /recommend/me?top_k=5` + `X-Dev-Uid: dev_user_1` |
| **Kỳ vọng** | Status **503**; `detail = "Firebase is not available"` |

---

## 5. Test thủ công trên server thật (tùy chọn, ngoài 6 pytest)

Dùng khi cần kiểm tra **Firestore + ML thật**, không dùng mock.

### 5.1 Chạy server

```powershell
.\.venv\Scripts\activate
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Cần file `serviceAccountKey.json` ở thư mục gốc project.

### 5.2 Các bước gợi ý

| Bước | Endpoint | Lệnh PowerShell | Pass khi |
|------|----------|-----------------|----------|
| M1 | `GET /` | `irm http://127.0.0.1:8000/` | Có `message` |
| M2 | `GET /health` | `irm http://127.0.0.1:8000/health` | `status = ok` |
| M3 | `GET /recommend` | `irm "http://127.0.0.1:8000/recommend?book_id=<ID>&top_k=5"` | 200 + list sách |
| M4 | `GET /recommend/me` (dev) | Set `$env:DEV_AUTH_BYPASS="true"`, restart server, gửi header `X-Dev-Uid` | 200 + list sách |

Swagger: `http://127.0.0.1:8000/docs`

---

## 6. Phân biệt 2 loại test

| Loại | Số lượng | File | Cần Firebase/ML thật? |
|------|----------|------|------------------------|
| **Pytest tự động** | **6 test** | `tests/test_recommend.py` | Không (mock) |
| **Test thủ công server** | 4 bước gợi ý (M1–M4) | Tài liệu mục 5 | Có |

---

## 7. Cấu trúc file liên quan

```text
ai-library-system/
├── app/
│   ├── main.py              # FastAPI app
│   └── api/routes.py        # Endpoints
├── tests/
│   ├── conftest.py          # Mock fixtures
│   └── test_recommend.py    # 6 testcase
├── pytest.ini
├── requirements-test.txt
├── reports/report.html      # Báo cáo sau pytest
└── TEST_KICH_BAN.md         # File này
```

---

## 8. Ghi chú cho báo cáo DACN

- **“6 passed”** = 6 testcase pytest trong `tests/test_recommend.py`, chạy bằng `pytest`, có báo cáo HTML.
- Test này chứng minh **API contract** (status, auth, lỗi 404/401/503, gọi service đúng).
- Đánh giá **chất lượng gợi ý** (sách giống nhau, phù hợp user) cần bổ sung test thủ công hoặc test E2E với Firestore thật.
