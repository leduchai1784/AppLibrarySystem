from fastapi import FastAPI
from app.services.recommender import recommend_books

app = FastAPI()

@app.get("/")
def root():
    return {"message": "AI Recommendation API running"}

@app.get("/recommend/{book_id}")
def recommend(book_id: str):
    return recommend_books(book_id)