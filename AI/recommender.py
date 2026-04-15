import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import datetime
import os
import sys

# Đảm bảo in tiếng Việt không lỗi trên Terminal Windows
sys.stdout.reconfigure(encoding='utf-8')

# --- 1. KẾT NỐI FIREBASE ---
# Thay đổi đường dẫn này trỏ tới file serviceAccountKey.json của bạn
SERVICE_ACCOUNT_KEY = 'serviceAccountKey.json'

def initialize_firebase():
    if not firebase_admin._apps:
        if not os.path.exists(SERVICE_ACCOUNT_KEY):
            print(f"LỖI: Không tìm thấy file '{SERVICE_ACCOUNT_KEY}'.")
            print("Vui lòng vào Firebase Console -> Project Settings -> Service Accounts -> Generate new private key.")
            exit(1)
        cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
        firebase_admin.initialize_app(cred)
    return firestore.client()

db = initialize_firebase()

# --- 2. HÀM LẤY DỮ LIỆU TỪ FIREBASE ---
def fetch_data():
    print("Đang tải dữ liệu sách...")
    books_ref = db.collection('books').stream()
    books_data = []
    for doc in books_ref:
        data = doc.to_dict()
        data['id'] = doc.id
        # Điền giá trị rỗng nếu thuộc tính thiếu
        data['title'] = data.get('title', '')
        data['description'] = data.get('description', '')
        data['author'] = data.get('author', '')
        books_data.append(data)
    
    df_books = pd.DataFrame(books_data)

    print("Đang tải dữ liệu mượn sách...")
    borrows_ref = db.collection('borrow_records').stream()
    borrows_data = []
    for doc in borrows_ref:
        data = doc.to_dict()
        data['id'] = doc.id
        borrows_data.append(data)
    
    print("Đang tải dữ liệu người dùng...")
    users_ref = db.collection('users').stream()
    users_data = [{'id': doc.id} for doc in users_ref]
    df_users = pd.DataFrame(users_data)
    df_borrows = pd.DataFrame(borrows_data)

    return df_books, df_borrows, df_users

# --- 3. THUẬT TOÁN AI (CONTENT-BASED FILTERING) ---
def build_recommendation_model(df_books):
    if df_books.empty:
        return None, None
        
    # Nối các trường văn bản lại với nhau để tạo thành một "văn bản đại diện" cho sách
    # Chúng ta dùng lowercase để chuẩn hóa
    df_books['content'] = (df_books['title'] + " " + 
                           df_books['author'] + " " + 
                           df_books['description']).str.lower()
    
    # Ở đây dùng Tfidf vectorizer để đánh giá độ quan trọng của từ
    tfidf = TfidfVectorizer(stop_words='english')
    # Nếu là tiếng Việt chủ đạo, có thể bỏ stop_words hoặc tự định nghĩa danh sách stop_words vn
    
    tfidf_matrix = tfidf.fit_transform(df_books['content'])
    
    # Tính ma trận cosin độ tương đồng giữa tất cả các sách
    cosine_sim = cosine_similarity(tfidf_matrix, tfidf_matrix)
    
    return df_books, cosine_sim

def generate_recommendations(df_books, df_borrows, df_users, cosine_sim):
    print("Bắt đầu tính toán gợi ý sách cho users...")
    recommendations_to_save = {}
    
    # 1. Tìm sách được mượn nhiều nhất chung (để fallback cho user chưa mượn gì)
    top_popular = []
    if not df_borrows.empty and not df_books.empty:
        popular_counts = df_borrows['bookId'].value_counts()
        top_popular_ids = popular_counts.head(10).index.tolist()
        top_popular = [vid for vid in top_popular_ids if vid in df_books['id'].values]
    
    # Danh sách toàn bộ user (hoặc chỉ những user có mượn nếu chưa có df_users)
    all_user_ids = df_users['id'].tolist() if not df_users.empty else (
        df_borrows['userId'].unique().tolist() if not df_borrows.empty else []
    )
    
    # Xây dựng danh mục sách để tra cứu index nhanh
    indices = pd.Series(df_books.index, index=df_books['id']).drop_duplicates()
    
    for user_id in all_user_ids:
        # Tìm các lượt mượn của user này
        if not df_borrows.empty and 'userId' in df_borrows.columns:
            user_borrows = df_borrows[df_borrows['userId'] == user_id]
            borrowed_book_ids = user_borrows['bookId'].unique()
        else:
            borrowed_book_ids = []
        
        # Lọc ra những bookIds mượn thực sự tồn tại trong danh sách books
        valid_borrowed_ids = [book_id for book_id in borrowed_book_ids if book_id in indices]
        
        if len(valid_borrowed_ids) == 0:
            # Fallback
            recommendations_to_save[user_id] = top_popular[:10]
            continue
            
        # Tính toán điểm tổng hợp từ những sách đã mượn
        sim_scores_total = []
        for book_id in valid_borrowed_ids:
            idx = indices[book_id]
            sim_scores = list(enumerate(cosine_sim[idx]))
            sim_scores_total.extend(sim_scores)
        
        # Gom nhóm kết quả giống như merge & sum
        book_scores = {}
        for idx, score in sim_scores_total:
            # Không gợi ý lại những sách đã mượn rồi
            if df_books.iloc[idx]['id'] not in valid_borrowed_ids:
                if idx in book_scores:
                    book_scores[idx] += score
                else:
                    book_scores[idx] = score
                    
        # Sắp xếp để lấy top 10 tốt nhất
        sorted_scores = sorted(book_scores.items(), key=lambda x: x[1], reverse=True)
        top_indices = [i[0] for i in sorted_scores[:10]]
        
        if not top_indices: # Nếu mượn hết sách rồi, không có gì gợi ý
             recommendations_to_save[user_id] = top_popular[:10]
        else:
             top_book_ids = df_books.iloc[top_indices]['id'].tolist()
             recommendations_to_save[user_id] = top_book_ids
        
    return recommendations_to_save, top_popular

# --- 4. GHI KẾT QUẢ ĐỂ CẬP NHẬT LÊN FIREBASE ---
def save_recommendations_to_firebase(recommendations, top_popular):
    print("Đang lưu gợi ý sách lên Firestore...")
    batch = db.batch()
    updated_count = 0
    
    # Lưu dưới sub-collection: users/{userId}/recommendations/home
    for user_id, book_ids in recommendations.items():
        if not book_ids:
            book_ids = top_popular[:10]
            
        doc_ref = db.collection('users').document(user_id).collection('recommendations').document('home')
        batch.set(doc_ref, {
            'recommendedBookIds': book_ids,
            'updatedAt': firestore.SERVER_TIMESTAMP,
            'type': 'ai_content_based'
        }, merge=True)
        
        updated_count += 1
        
        if updated_count % 400 == 0: # Firestore giới hạn 500 set per batch
            batch.commit()
            batch = db.batch()
            
    if updated_count % 400 != 0:
        batch.commit()
        
    print(f"Hoàn thành! Đã cập nhật gợi ý cho {updated_count} users.")

# --- CHẠY MAIN ---
if __name__ == "__main__":
    print("--- BẮT ĐẦU CHẠY BATCH AI SÁCH ---")
    df_books, df_borrows, df_users = fetch_data()
    
    print(f"Tổng số sách lấy được: {len(df_books)}")
    print(f"Tổng số lượt mượn: {len(df_borrows)}")
    print(f"Tổng số user phân tích: {len(df_users)}")
    
    df_books_processed, cosine_sim = build_recommendation_model(df_books)
    if df_books_processed is not None:
        recs, top_pop = generate_recommendations(df_books_processed, df_borrows, df_users, cosine_sim)
        save_recommendations_to_firebase(recs, top_pop)
    else:
        print("Không có sách nào trong database, bỏ qua chạy máy học.")
