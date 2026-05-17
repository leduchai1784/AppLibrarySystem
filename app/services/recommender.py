from __future__ import annotations

import math
import threading
import time
import datetime as dt
from collections import Counter
from typing import Any, Dict, List, Optional, Set, Tuple

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from app.core.config import settings
from app.models.book import Book
from app.services.firebase_service import get_firebase_service


class Recommender:
    """
    TF-IDF recommender with:
    - item-item similarity (book -> similar books)
    - user profile similarity (history -> similar in-stock books)
    - periodic refresh based on Firestore snapshot fingerprint + TTL
    """

    def __init__(self, books_csv_path: str | None = None) -> None:
        self._books_csv_path = books_csv_path or settings.books_csv_path
        self._lock = threading.Lock()

        self._df = pd.DataFrame()
        self._id_to_index: dict[str, int] = {}
        self._books: List[Book] = []

        self._vectorizer: TfidfVectorizer | None = None
        self._tfidf = None
        self._similarity = None

        self._fingerprint: str | None = None
        self._last_refresh_monotonic: float = 0.0

        self._rebuild_model()

    def _rebuild_model(self) -> None:
        df, fp = self._load_books_df()
        books = [self._row_to_book(r) for r in df.to_dict(orient="records")]
        id_to_index = {str(row_id): idx for idx, row_id in enumerate(df["id"].tolist())}

        if len(books) == 0:
            vectorizer = None
            tfidf = None
            similarity = None
        else:
            corpus = (df["title"] + " " + df["genre"] + " " + df["description"]).fillna("")
            vectorizer = TfidfVectorizer(stop_words="english", max_features=50_000, ngram_range=(1, 2))
            tfidf = vectorizer.fit_transform(corpus.tolist())
            similarity = cosine_similarity(tfidf, tfidf)

        with self._lock:
            self._df = df
            self._id_to_index = id_to_index
            self._books = books
            self._vectorizer = vectorizer
            self._tfidf = tfidf
            self._similarity = similarity
            if fp is not None:
                self._fingerprint = fp

    def maybe_refresh(self) -> None:
        if not settings.firebase_enabled:
            return

        now = time.monotonic()
        ttl = max(5, int(settings.recommender_refresh_ttl_seconds))
        if (now - self._last_refresh_monotonic) < ttl:
            return

        fb = get_firebase_service()
        snap = fb.get_books_snapshot()
        fp = str(snap.get("fingerprint") or "")

        # Cheap fingerprint check (no model rebuild needed)
        if fp and fp == (self._fingerprint or ""):
            self._last_refresh_monotonic = time.monotonic()
            return

        if fp and fp != (self._fingerprint or ""):
            self._rebuild_model()
            self._last_refresh_monotonic = time.monotonic()
            return

        self._last_refresh_monotonic = time.monotonic()

    def _load_books_df(self) -> tuple[pd.DataFrame, str | None]:
        if settings.firebase_enabled:
            fb = get_firebase_service()
            snap = fb.get_books_snapshot()
            rows = snap.get("rows") or []
            fp = snap.get("fingerprint")
            if rows:
                return self._normalize_firestore_rows(rows), (str(fp) if fp is not None else None)
            return (
                pd.DataFrame(
                columns=[
                    "id",
                    "title",
                    "author",
                    "genre",
                    "description",
                    "category",
                    "availableQuantity",
                    "available",
                    "quantity",
                    "isAvailable",
                    "totalBorrowCount",
                    "borrowCount",
                ]
                ),
                (str(fp) if fp is not None else None),
            )

        df = pd.read_csv(self._books_csv_path)
        required = {"id", "title", "author", "genre", "description"}
        missing = required - set(df.columns)
        if missing:
            raise ValueError(f"books.csv missing columns: {sorted(missing)}")

        df = df[list(required)].copy()
        df["id"] = df["id"].astype(str)
        for col in ["title", "author", "genre", "description"]:
            df[col] = df[col].fillna("").astype(str)

        df = df.drop_duplicates(subset=["id"]).reset_index(drop=True)
        return df, None

    @staticmethod
    def _normalize_firestore_rows(rows: List[dict]) -> pd.DataFrame:
        out_rows: List[dict] = []
        for r in rows:
            rid = str(r.get("id") or "")
            if not rid:
                continue

            title = "" if r.get("title") is None else str(r.get("title"))
            author = "" if r.get("author") is None else str(r.get("author"))
            category = "" if r.get("category") is None else str(r.get("category"))
            genre = r.get("genre")
            if genre is None or str(genre).strip() == "":
                genre = category
            genre = "" if genre is None else str(genre)
            description = "" if r.get("description") is None else str(r.get("description"))

            out_rows.append(
                {
                    "id": rid,
                    "title": title,
                    "author": author,
                    "genre": genre,
                    "description": description,
                    "category": category,
                    "availableQuantity": r.get("availableQuantity", float("nan")),
                    "available": r.get("available", float("nan")),
                    "quantity": r.get("quantity", float("nan")),
                    "isAvailable": r.get("isAvailable", None),
                    "totalBorrowCount": r.get("totalBorrowCount", float("nan")),
                    "borrowCount": r.get("borrowCount", float("nan")),
                }
            )

        df = pd.DataFrame(out_rows)
        if df.empty:
            return df

        for col in ["availableQuantity", "available", "quantity", "totalBorrowCount", "borrowCount"]:
            df[col] = pd.to_numeric(df[col], errors="coerce")

        def _effective_available(row: pd.Series) -> float:
            for key in ("availableQuantity", "available", "quantity"):
                val = row.get(key)
                if pd.isna(val):
                    continue
                return float(val)
            return 0.0

        df["__effective_available"] = df.apply(_effective_available, axis=1)

        def _in_stock(row: pd.Series) -> bool:
            if row.get("isAvailable") is False:
                return False
            return float(row["__effective_available"]) > 0

        df["__in_stock"] = df.apply(_in_stock, axis=1)
        df = df.drop_duplicates(subset=["id"]).reset_index(drop=True)
        return df

    @staticmethod
    def _row_to_book(row: dict) -> Book:
        return Book(
            id=str(row["id"]),
            title=str(row.get("title", "")),
            author=str(row.get("author", "")),
            genre=str(row.get("genre", "")),
            description=str(row.get("description", "")),
            category=(None if row.get("category") in (None, "") else str(row.get("category"))),
            availableQuantity=(None if pd.isna(row.get("availableQuantity")) else float(row.get("availableQuantity"))),
            available=(None if pd.isna(row.get("available")) else float(row.get("available"))),
            quantity=(None if pd.isna(row.get("quantity")) else float(row.get("quantity"))),
            isAvailable=(None if row.get("isAvailable") is None else bool(row.get("isAvailable"))),
        )

    def get_book(self, book_id: str) -> Book | None:
        self.maybe_refresh()
        idx = self._id_to_index.get(str(book_id))
        if idx is None:
            return None
        return self._books[idx]

    def recommend(self, book_id: str, top_k: int = 5) -> List[Book]:
        self.maybe_refresh()
        if self._similarity is None:
            return []
        idx = self._id_to_index.get(str(book_id))
        if idx is None:
            return []

        sims = self._similarity[idx]
        candidates = sorted(enumerate(sims), key=lambda x: x[1], reverse=True)

        out: List[Book] = []
        for other_idx, _score in candidates:
            if other_idx == idx:
                continue
            if not bool(self._df.iloc[other_idx].get("__in_stock", False)):
                continue
            out.append(self._books[other_idx])
            if len(out) >= top_k:
                break
        return out

    def recommend_for_user(
        self,
        borrow_records: List[Dict[str, Any]],
        top_k: int = 10,
        exclude_book_ids: Optional[Set[str]] = None,
    ) -> List[Book]:
        self.maybe_refresh()
        exclude_book_ids = exclude_book_ids or set()
        exclude_book_ids = {str(x) for x in exclude_book_ids}

        if self._vectorizer is None or self._tfidf is None:
            return []

        book_weights, profile_book_ids = self._weights_from_borrow_records(borrow_records)
        if not profile_book_ids:
            return self._popular_in_stock(top_k=top_k, exclude=exclude_book_ids)

        idxs: List[int] = []
        for bid in profile_book_ids:
            idx = self._id_to_index.get(bid)
            if idx is not None:
                idxs.append(idx)
        if not idxs:
            return self._popular_in_stock(top_k=top_k, exclude=exclude_book_ids)

        # Weighted profile text:
        # - includes currently borrowed books in the profile
        # - down-weights returned books (exponential decay by borrow age)
        parts: List[str] = []
        for bid in profile_book_ids:
            idx = self._id_to_index.get(bid)
            if idx is None:
                continue
            row = self._df.iloc[idx]
            chunk = str(row["title"]) + " " + str(row["genre"]) + " " + str(row["description"])
            w = float(book_weights.get(bid, 1.0))
            repeats = int(max(1, min(3, round(w * 2))))  # keep small for performance
            parts.extend([chunk] * repeats)
        profile_text = " \n ".join(parts)

        q = self._vectorizer.transform([profile_text])
        sims = cosine_similarity(q, self._tfidf)[0]

        pool = max(top_k, int(settings.recommend_candidate_pool))
        ranked = sorted(enumerate(sims), key=lambda x: x[1], reverse=True)

        cat_pref, auth_pref = self._preference_maps(profile_book_ids, book_weights)

        scored: List[Tuple[int, float]] = []
        for other_idx, s_sim in ranked:
            book = self._books[other_idx]
            if book.id in exclude_book_ids:
                continue
            if not bool(self._df.iloc[other_idx].get("__in_stock", False)):
                continue

            row = self._df.iloc[other_idx]
            cat = str(row.get("category") or "")
            auth = str(row.get("author") or "")

            s_cat = 1.0 if cat and cat_pref.get(cat, 0.0) > 0 else 0.0
            s_auth = 1.0 if auth and auth_pref.get(auth, 0.0) > 0 else 0.0

            pop = row.get("totalBorrowCount")
            pop = 0.0 if pop is None or (isinstance(pop, float) and math.isnan(float(pop))) else float(pop)
            s_pop = math.log1p(max(0.0, pop)) / 10.0

            score = (
                1.0 * float(s_sim)
                + 0.35 * s_cat
                + 0.25 * s_auth
                + 0.20 * s_pop
            )
            scored.append((other_idx, score))

        scored.sort(key=lambda x: x[1], reverse=True)
        scored = scored[:pool]

        max_per_cat = max(1, int(settings.recommend_max_per_category))
        cat_counts: Counter[str] = Counter()
        out: List[Book] = []
        for other_idx, _score in scored:
            book = self._books[other_idx]
            row = self._df.iloc[other_idx]
            cat = str(row.get("category") or "") or "__unknown__"
            if cat_counts[cat] >= max_per_cat:
                continue
            cat_counts[cat] += 1
            out.append(book)
            if len(out) >= top_k:
                break
        return out

    def _popular_in_stock(self, top_k: int, exclude: Set[str]) -> List[Book]:
        if self._df.empty:
            return []

        df = self._df.copy()
        df = df[df["__in_stock"] == True]  # noqa: E712
        df = df[~df["id"].astype(str).isin(exclude)]

        score = pd.Series(0.0, index=df.index)
        if "totalBorrowCount" in df.columns:
            score = score + df["totalBorrowCount"].fillna(0)

        # Tie-breaker: longer descriptions tend to be richer items (weak heuristic)
        score = score + (df["description"].fillna("").str.len() / 5000.0)

        df = df.assign(__score=score).sort_values("__score", ascending=False)
        out: List[Book] = []
        for bid in df["id"].astype(str).tolist():
            idx = self._id_to_index.get(bid)
            if idx is None:
                continue
            out.append(self._books[idx])
            if len(out) >= top_k:
                break
        return out

    @staticmethod
    def _as_utc(dt_value: object) -> dt.datetime:
        if isinstance(dt_value, dt.datetime):
            if dt_value.tzinfo is None:
                return dt_value.replace(tzinfo=dt.timezone.utc)
            return dt_value.astimezone(dt.timezone.utc)
        return dt.datetime.min.replace(tzinfo=dt.timezone.utc)

    def _weights_from_borrow_records(self, borrow_records: List[Dict[str, Any]]) -> tuple[dict[str, float], List[str]]:
        now = dt.datetime.now(tz=dt.timezone.utc)
        half_life_days = max(1, int(settings.recommend_returned_half_life_days))

        weights: dict[str, float] = {}
        order: List[str] = []

        # borrow_records are expected newest-first (FirebaseService.get_user_history)
        for rec in borrow_records:
            bid = rec.get("bookId")
            if not bid:
                continue
            bid = str(bid)

            status = str(rec.get("status") or "")
            return_date = rec.get("returnDate")

            if status == "borrowing" and return_date is None:
                w = 1.0
            else:
                bd = self._as_utc(rec.get("borrowDate"))
                age_days = max(0.0, (now - bd).total_seconds() / 86400.0)
                w = math.exp(-(age_days / float(half_life_days)) * math.log(2.0))

            if bid not in weights:
                order.append(bid)
            weights[bid] = max(weights.get(bid, 0.0), float(w))

        return weights, order

    def _preference_maps(
        self,
        profile_book_ids: List[str],
        book_weights: dict[str, float],
    ) -> tuple[dict[str, float], dict[str, float]]:
        cat = Counter()
        auth = Counter()
        for bid in profile_book_ids:
            idx = self._id_to_index.get(bid)
            if idx is None:
                continue
            row = self._df.iloc[idx]
            w = float(book_weights.get(bid, 1.0))
            c = str(row.get("category") or "").strip()
            a = str(row.get("author") or "").strip()
            if c:
                cat[c] += w
            if a:
                auth[a] += w

        def norm(counter: Counter) -> dict[str, float]:
            total = float(sum(counter.values()) or 1.0)
            return {k: float(v) / total for k, v in counter.items()}

        return norm(cat), norm(auth)


_instance: Recommender | None = None
_lock = threading.Lock()


def get_recommender() -> Recommender:
    global _instance
    if _instance is not None:
        return _instance
    with _lock:
        if _instance is None:
            _instance = Recommender()
    return _instance

