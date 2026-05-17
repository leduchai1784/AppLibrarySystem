import pytest
from fastapi.testclient import TestClient

from app.main import app

# Tên hiển thị ngắn (tiếng Việt) trên báo cáo HTML
TEST_TEN_HIEN_THI = {
    "tests/test_recommend.py::test_recommend_success": "TC01 — Gợi ý theo book_id (HTTP 200)",
    "tests/test_recommend.py::test_recommend_book_not_found": "TC02 — book_id không tồn tại (HTTP 404)",
    "tests/test_recommend.py::test_recommend_me_success_dev_auth": "TC03 — Gợi ý cá nhân (dev X-Dev-Uid)",
    "tests/test_recommend.py::test_recommend_me_success_bearer_auth": "TC04 — Gợi ý cá nhân (Bearer token)",
    "tests/test_recommend.py::test_recommend_me_missing_auth": "TC05 — Thiếu xác thực (HTTP 401)",
    "tests/test_recommend.py::test_recommend_me_firebase_inactive": "TC06 — Firebase không khả dụng (HTTP 503)",
}

# Mô tả nghiệp vụ (tiếng Việt) hiển thị trên báo cáo HTML
TEST_MO_TA_NGHIEP_VU = {
    "tests/test_recommend.py::test_recommend_success": (
        "Gợi ý sách theo mã sách: khi book_id hợp lệ, API trả HTTP 200 và danh sách sách gợi ý."
    ),
    "tests/test_recommend.py::test_recommend_book_not_found": (
        "Gợi ý theo mã sách: khi book_id không tồn tại, API trả HTTP 404 với thông báo «Book not found»."
    ),
    "tests/test_recommend.py::test_recommend_me_success_dev_auth": (
        "Gợi ý cá nhân: dùng chế độ dev (header X-Dev-Uid), trả HTTP 200 và loại sách đang mượn khỏi kết quả."
    ),
    "tests/test_recommend.py::test_recommend_me_success_bearer_auth": (
        "Gợi ý cá nhân: xác thực bằng Bearer token Firebase, trả HTTP 200 và đọc lịch sử mượn của user."
    ),
    "tests/test_recommend.py::test_recommend_me_missing_auth": (
        "Gợi ý cá nhân: không gửi token/header, API từ chối với HTTP 401."
    ),
    "tests/test_recommend.py::test_recommend_me_firebase_inactive": (
        "Gợi ý cá nhân: khi Firebase không khả dụng, API trả HTTP 503."
    ),
}

_KET_QUA_TIENG_VIET = {
    "passed": "Đạt",
    "failed": "Không đạt",
    "skipped": "Bỏ qua",
    "rerun": "Chạy lại",
    "error": "Lỗi",
    "xfailed": "Lỗi kỳ vọng",
    "xpassed": "Đạt ngoài kỳ vọng",
}


def pytest_html_report_title(report):
    report.title = "Báo cáo kiểm thử API — Hệ thống thư viện AI"


def pytest_html_results_summary(prefix, summary, postfix, session):
    prefix.extend(
        [
            '<div class="summary-intro">'
            "<h2>Tổng quan</h2>"
            "<p>Báo cáo này ghi lại kết quả <strong>kiểm thử tự động</strong> các API gợi ý sách "
            "(theo sách và theo người dùng).</p>"
            "</div>"
        ]
    )
    postfix.extend(
        [
            "<script>"
            "document.addEventListener('DOMContentLoaded',function(){"
            "const labels={passed:'Đạt',failed:'Không đạt',skipped:'Bỏ qua',"
            "error:'Lỗi',xfailed:'Lỗi kỳ vọng',xpassed:'Đạt ngoài kỳ vọng',rerun:'Chạy lại'};"
            "document.querySelectorAll('.filters span').forEach(function(span){"
            "for(const key in labels){"
            "if(span.classList.contains(key)){"
            "span.textContent=span.textContent.replace(new RegExp(key,'i'),labels[key]);"
            "break;}}});"
            "var hint=document.querySelector('p.filter');"
            "if(hint){hint.textContent='Bật/tắt ô lọc để hiển thị kết quả theo trạng thái.';}"
            "});"
            "</script>"
        ]
    )


def pytest_html_results_table_header(cells):
    cells[0] = '<th class="sortable result" data-column-type="result">Kết quả</th>'
    cells[1] = '<th class="sortable" data-column-type="testId">Tên kỹ thuật</th>'
    cells.insert(
        2,
        '<th class="sortable" data-column-type="text">Tên test</th>',
    )
    cells.insert(
        3,
        '<th class="sortable" data-column-type="text">Mô tả nghiệp vụ</th>',
    )
    if len(cells) > 4:
        cells[4] = '<th class="sortable time" data-column-type="duration">Thời gian</th>'
    if len(cells) > 5:
        cells[5] = "<th>Liên kết</th>"


def pytest_html_results_table_row(report, cells):
    # Giữ Passed/Failed trong ô kết quả — pytest-html lọc theo giá trị tiếng Anh này.
    ket_qua = _KET_QUA_TIENG_VIET.get(report.outcome, report.outcome)
    if cells[0].startswith('<td class="col-result">'):
        cells[0] = cells[0].replace(
            '<td class="col-result">',
            f'<td class="col-result" title="Kết quả: {ket_qua}">',
            1,
        )

    ten_hien_thi = TEST_TEN_HIEN_THI.get(
        report.nodeid, report.nodeid.split("::")[-1]
    )
    mo_ta = TEST_MO_TA_NGHIEP_VU.get(report.nodeid, "—")
    cells.insert(2, f'<td class="col-testName">{ten_hien_thi}</td>')
    cells.insert(3, f'<td class="col-description">{mo_ta}</td>')

@pytest.fixture
def test_client():
    """
    Returns a FastAPI TestClient instance for testing routes.
    """
    with TestClient(app) as client:
        yield client

@pytest.fixture
def mock_recommender(mocker):
    """
    Mocks the Recommender model to prevent loading real ML models or database during tests.
    """
    # Create a mock instance with common return values
    mock_rec_instance = mocker.Mock()
    
    # Mock get_book to return a dummy dictionary if needed, or None
    mock_rec_instance.get_book.return_value = {
        "id": "book_1",
        "title": "Mock Book 1",
        "author": "Mock Author",
        "genre": "Fiction",
        "description": "A mock book"
    }
    
    # Mock recommend to return a list of dummy books
    mock_rec_instance.recommend.return_value = [
        {"id": "book_2", "title": "Recommended Book 2", "author": "A", "genre": "B", "description": "C"},
        {"id": "book_3", "title": "Recommended Book 3", "author": "X", "genre": "Y", "description": "Z"}
    ]
    
    # Mock recommend_for_user
    mock_rec_instance.recommend_for_user.return_value = [
        {"id": "book_4", "title": "User Recommended Book 4", "author": "P", "genre": "Q", "description": "R"},
        {"id": "book_5", "title": "User Recommended Book 5", "author": "L", "genre": "M", "description": "N"}
    ]
    
    # Patch the get_recommender function used in endpoints
    mocker.patch('app.api.routes.get_recommender', return_value=mock_rec_instance)
    return mock_rec_instance


@pytest.fixture
def mock_firebase(mocker):
    """
    Mocks the Firebase Service to avoid external network calls during tests.
    """
    mock_fb_instance = mocker.Mock()
    
    # Simulate initialized state
    mock_fb_instance.active = True
    mock_fb_instance.ensure_initialized.return_value = None
    
    # Mock get_user_history
    mock_fb_instance.get_user_history.return_value = [
        {"bookId": "history_book_1", "status": "returned", "returnDate": "2023-01-01"},
        {"bookId": "history_book_2", "status": "borrowing", "returnDate": None} # currently borrowing
    ]
    
    # Patch the get_firebase_service function
    mocker.patch('app.api.routes.get_firebase_service', return_value=mock_fb_instance)
    
    # We also need to mock Firebase auth parsing functions since we bypass/verify auth
    mocker.patch('app.api.routes.parse_bearer_authorization', return_value="mocked_token")
    mocker.patch('app.api.routes.verify_firebase_id_token', return_value={"uid": "test_uid"})
    mocker.patch('app.api.routes.uid_from_claims', return_value="test_uid")
    
    return mock_fb_instance
