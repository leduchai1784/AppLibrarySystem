import logging
from typing import List, Optional, Set

from fastapi import APIRouter, Header, HTTPException, Query

from app.core.config import settings
from app.models.book import Book
from app.services.firebase_auth import parse_bearer_authorization, uid_from_claims, verify_firebase_id_token
from app.services.firebase_service import get_firebase_service
from app.services.recommender import get_recommender

logger = logging.getLogger("app.api")

router = APIRouter()


@router.get("/")
def root() -> dict:
    return {
        "message": "API is running successfully",
        "service": "book-recommendation-api",
        "endpoints": [
            "/health",
            "/recommend?book_id=<firestore_doc_id>&top_k=5",
            "/recommend/me?top_k=10 (Authorization: Bearer <Firebase ID token>)",
        ],
    }


@router.get("/health")
def health() -> dict:
    return {"status": "ok"}


@router.get("/recommend", response_model=List[Book])
def recommend(
    book_id: str = Query(..., min_length=1),
    top_k: int = Query(5, ge=1, le=50),
) -> List[Book]:
    rec = get_recommender()
    book = rec.get_book(book_id)
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    result = rec.recommend(book_id=book_id, top_k=top_k)
    return result


@router.get("/recommend/me", response_model=List[Book])
def recommend_me(
    top_k: int = Query(10, ge=1, le=50),
    authorization: Optional[str] = Header(default=None),
    x_dev_uid: Optional[str] = Header(default=None, alias="X-Dev-Uid"),
) -> List[Book]:
    """
    Personalized recommendations:
    - Uses borrow_records for the authenticated user (Firebase Auth UID).
    - Filters to in-stock books (availableQuantity ?? available ?? quantity, plus isAvailable=false rule).
    """
    if settings.dev_auth_bypass and x_dev_uid:
        uid = x_dev_uid.strip()
        if not uid:
            raise HTTPException(status_code=401, detail="Invalid X-Dev-Uid")
    else:
        token = parse_bearer_authorization(authorization)
        if not token:
            raise HTTPException(status_code=401, detail="Missing Authorization: Bearer <Firebase ID token>")
        claims = verify_firebase_id_token(token)
        uid = uid_from_claims(claims)

    fb = get_firebase_service()
    fb.ensure_initialized()
    if not fb.active:
        raise HTTPException(status_code=503, detail="Firebase is not available")

    history = fb.get_user_history(uid, limit=200)

    active_borrow_ids: Set[str] = set()
    for h in history:
        bid = h.get("bookId")
        if not bid:
            continue
        bid = str(bid)
        st = str(h.get("status") or "")
        ret = h.get("returnDate")
        if st == "borrowing" and ret is None:
            active_borrow_ids.add(bid)

    rec = get_recommender()
    return rec.recommend_for_user(
        borrow_records=history,
        top_k=top_k,
        exclude_book_ids=active_borrow_ids,
    )

