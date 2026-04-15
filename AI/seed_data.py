import firebase_admin
from firebase_admin import credentials, firestore
import random
import datetime
import os

SERVICE_ACCOUNT_KEY = 'serviceAccountKey.json'

def initialize_firebase():
    if not firebase_admin._apps:
        if not os.path.exists(SERVICE_ACCOUNT_KEY):
            print(f"LỖI: Không tìm thấy '{SERVICE_ACCOUNT_KEY}'.")
            exit(1)
        cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
        firebase_admin.initialize_app(cred)
    return firestore.client()

db = initialize_firebase()

def seed_data():
    print("Vui lòng chờ... Đang đẩy dữ liệu dummy...")
    
    # 1. Tạo 10 cuốn sách ngẫu nhiên
    books_data = [
        {"title": "Lập trình Flutter cơ bản", "author": "Nguyễn Văn A", "description": "Sách dạy lập trình mobile đa nền tảng với Flutter từ cơ bản đến nâng cao."},
        {"title": "Cấu trúc dữ liệu và giải thuật", "author": "Trần B", "description": "Tài liệu môn học thuật toán, cây, đồ thị, tìm kiếm cơ bản dành cho sinh viên IT."},
        {"title": "Lập trình Python nhập môn", "author": "Lê C", "description": "Sách hướng dẫn học mã nguồn mở Python nhanh chóng, làm AI phân tích dữ liệu."},
        {"title": "Machine Learning căn bản", "author": "Hoàng D", "description": "Học máy cho người mới bắt đầu. Regression, Neural Network cơ bản, thuật toán AI."},
        {"title": "Nghệ thuật giao tiếp", "author": "Trịnh E", "description": "Sách kỹ năng mềm, nghệ thuật giao tiếp tạo thiện cảm trong công việc."},
        {"title": "Đắc nhân tâm", "author": "Dale Carnegie", "description": "Tác phẩm hay nhất về kỹ năng sống, thu phục lòng người."},
        {"title": "Lập trình Dart", "author": "Vũ F", "description": "Kỹ thuật chuyên sâu về ngôn ngữ Dart áp dụng cho framework Flutter."},
        {"title": "Học máy nâng cao", "author": "Hoàng D", "description": "Tiếp nối ML căn bản, chuyên sâu về Deep Learning và Recommendation System bằng AI."},
        {"title": "Lịch sử Việt Nam", "author": "Nguyễn Trãi", "description": "Tác phẩm lịch sử về các triều đại phong kiến của đất nước Việt Nam."},
        {"title": "Làm chủ Firebase và GCP", "author": "Phạm H", "description": "Sách dạy cách sử dụng Cloud services, Firestore, Auth, Storage."}
    ]
    
    book_ids = []
    for bk in books_data:
        _, doc_ref = db.collection('books').add({
            'title': bk['title'],
            'author': bk['author'],
            'description': bk['description'],
            'createdAt': firestore.SERVER_TIMESTAMP,
            'isAvailable': True
        })
        book_ids.append(doc_ref.id)
        
    print(f"Đã tạo {len(book_ids)} sách dummy.")

    # 2. Tạo User dummy (3 user)
    user_ids = []
    for i in range(3):
        doc_ref = db.collection('users').document(f'dummy_user_{i}')
        doc_ref.set({
            'fullName': f'Sinh Viên {i+1}',
            'role': 'student',
            'email': f'student{i+1}@dummy.com',
            'createdAt': firestore.SERVER_TIMESTAMP
        })
        user_ids.append(f'dummy_user_{i}')
        
    print(f"Đã tạo {len(user_ids)} người dùng dummy.")

    # 3. Tạo một số lịch sử mượn (để Test AI)
    # User 0 thích Mobile & Firebase (sách số 0, 6, 9)
    # User 1 thích AI & Python (sách số 2, 3, 7)
    # User 2 thích Kỹ năng sống & Lịch sử (sách số 4, 5, 8)
    
    borrows = [
        {"userId": user_ids[0], "bookId": book_ids[0]},
        {"userId": user_ids[0], "bookId": book_ids[6]},
        {"userId": user_ids[0], "bookId": book_ids[9]},
        
        {"userId": user_ids[1], "bookId": book_ids[2]},
        {"userId": user_ids[1], "bookId": book_ids[3]},
        
        {"userId": user_ids[2], "bookId": book_ids[4]},
        {"userId": user_ids[2], "bookId": book_ids[5]},
        {"userId": user_ids[2], "bookId": book_ids[8]},
    ]
    
    for b in borrows:
        db.collection('borrow_records').add({
            'userId': b['userId'],
            'bookId': b['bookId'],
            'borrowDate': firestore.SERVER_TIMESTAMP,
            'status': 'returned'
        })
        
    print("Đã tạo lượt mượn dummy thành công!")
    print("=> GIỜ BẠN CÓ THỂ CHẠY 'python recommender.py' ĐỂ TEST.")

if __name__ == "__main__":
    reply = input("CẢNH BÁO: Thao tác này sẽ tự chèn dữ liệu không thật lên database của bạn. Bạn có muốn tiếp tục? (y/n): ")
    if reply.lower() == 'y':
        seed_data()
    else:
        print("Đã huỷ.")
