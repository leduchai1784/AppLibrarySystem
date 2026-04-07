from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from app.services.firebase_service import get_all_books

def recommend_books(book_id: str):
    books = get_all_books()

    if not books:
        return []

    # 🔥 Kết hợp nhiều field để AI hiểu tốt hơn
    corpus = [
        (
            b["title"] + " " +
            b["description"] + " " +
            b["category"] + " " +
            b["author"]
        )
        for b in books
    ]

    vectorizer = TfidfVectorizer()
    vectors = vectorizer.fit_transform(corpus)

    # tìm index
    index = next((i for i, b in enumerate(books) if b["id"] == book_id), None)

    if index is None:
        return []

    sim_scores = cosine_similarity(vectors[index], vectors).flatten()

    # lấy top 5 giống nhất
    similar_indices = sim_scores.argsort()[::-1][1:6]

    result = [books[i] for i in similar_indices]

    return result