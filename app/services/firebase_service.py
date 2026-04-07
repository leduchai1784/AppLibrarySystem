import firebase_admin
from firebase_admin import credentials, firestore
from app.config import FIREBASE_KEY

cred = credentials.Certificate(FIREBASE_KEY)
firebase_admin.initialize_app(cred)

db = firestore.client()

def get_all_books():
    docs = db.collection("books").stream()
    books = []

    for doc in docs:
        data = doc.to_dict()

        books.append({
            "id": doc.id,
            "title": data.get("title", ""),
            "description": data.get("description", ""),
            "category": data.get("category", ""),
            "author": data.get("author", ""),
            "availableQuantity": data.get("availableQuantity", 0),
            "isAvailable": data.get("isAvailable", False)
        })

    return books