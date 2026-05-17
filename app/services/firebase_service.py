from __future__ import annotations

import datetime as _dt
import logging
from typing import Any, Dict, List, Optional

from app.core.config import settings

logger = logging.getLogger("app.firebase")


class FirebaseService:
    """
    Optional Firebase Admin integration.

    - Safe to import even when firebase-admin is not installed or not configured.
    - Initialization happens lazily and only once.
    """

    def __init__(self) -> None:
        self._enabled = settings.firebase_enabled
        self._initialized = False
        self._db = None
        self._last_error: str | None = None

    def _init_if_needed(self) -> None:
        if not self._enabled:
            return
        if self._initialized:
            return

        try:
            import firebase_admin  # type: ignore
            from firebase_admin import credentials, firestore  # type: ignore

            if not firebase_admin._apps:
                if settings.firebase_credential_path:
                    cred = credentials.Certificate(settings.firebase_credential_path)
                    firebase_admin.initialize_app(cred)
                else:
                    firebase_admin.initialize_app()

            self._db = firestore.client()
            self._initialized = True
            self._last_error = None
            logger.info("Firebase initialized")
        except Exception as e:  # noqa: BLE001
            logger.warning("Firebase init failed: %s", e)
            self._enabled = False
            self._initialized = False
            self._db = None
            self._last_error = str(e)

    @property
    def configured(self) -> bool:
        return bool(settings.firebase_enabled)

    @property
    def initialized(self) -> bool:
        return bool(self._initialized and self._db is not None)

    @property
    def active(self) -> bool:
        return bool(self._enabled and self._initialized and self._db is not None)

    def health(self) -> Dict[str, Any]:
        """
        Lightweight health payload (safe for clients): reflects real Admin SDK init state.
        """
        self._init_if_needed()

        books_count: int | None = None
        if self.active:
            try:
                books_count = len(self.get_books())
            except Exception as e:  # noqa: BLE001
                books_count = None
                self._last_error = str(e)

        status = "disabled"
        if self.configured and not self.active:
            status = "misconfigured" if self._last_error else "down"
        elif self.active:
            status = "ok" if books_count is not None else "degraded"

        return {
            "status": status,
            "configured": self.configured,
            "admin_sdk_initialized": self.initialized,
            "firestore_client": self.active,
            "credential_configured": bool(settings.firebase_credential_path),
            "books_count": books_count,
            "last_error": self._last_error,
        }

    def ensure_initialized(self) -> None:
        self._init_if_needed()

    def get_books(self) -> List[Dict[str, Any]]:
        return self.get_books_snapshot()["rows"]

    def get_books_snapshot(self) -> Dict[str, Any]:
        self._init_if_needed()
        if not self._enabled or self._db is None:
            return {"rows": [], "count": 0, "max_updated_at": None, "fingerprint": "disabled"}

        try:
            docs = self._db.collection("books").stream()
            out: List[Dict[str, Any]] = []
            max_updated_at: _dt.datetime | None = None
            for d in docs:
                data = d.to_dict() or {}
                # Use Firestore document id as primary id (supports random string ids).
                data["id"] = str(data.get("id") or d.id)
                # Map schema's primary category field into a single string for recommendations.
                if "genre" not in data:
                    data["genre"] = data.get("category") or ""
                out.append(data)

                ua = data.get("updatedAt")
                if isinstance(ua, _dt.datetime):
                    if ua.tzinfo is None:
                        ua = ua.replace(tzinfo=_dt.timezone.utc)
                    else:
                        ua = ua.astimezone(_dt.timezone.utc)
                    max_updated_at = ua if max_updated_at is None or ua > max_updated_at else max_updated_at

            fingerprint = f"c={len(out)}|max={max_updated_at.isoformat() if max_updated_at else 'none'}"
            return {"rows": out, "count": len(out), "max_updated_at": max_updated_at, "fingerprint": fingerprint}
        except Exception as e:  # noqa: BLE001
            logger.warning("get_books failed: %s", e)
            return {"rows": [], "count": 0, "max_updated_at": None, "fingerprint": f"error:{e}"}

    def get_book(self, book_id: str) -> Optional[Dict[str, Any]]:
        self._init_if_needed()
        if not self._enabled or self._db is None:
            return None

        try:
            # Prefer document id == book_id (supports random string ids)
            doc = self._db.collection("books").document(str(book_id)).get()
            if doc.exists:
                data = doc.to_dict() or {}
                data.setdefault("id", str(book_id))
                if "genre" not in data:
                    data["genre"] = data.get("category") or ""
                return data

            # Fallback: query by "id" field (string)
            q = self._db.collection("books").where("id", "==", str(book_id)).limit(1).stream()
            for d in q:
                data = d.to_dict() or {}
                data.setdefault("id", str(book_id))
                if "genre" not in data:
                    data["genre"] = data.get("category") or ""
                return data
            return None
        except Exception as e:  # noqa: BLE001
            logger.warning("get_book failed: %s", e)
            return None

    def get_user_history(self, user_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        self._init_if_needed()
        if not self._enabled or self._db is None:
            return []

        try:
            # According to DATABASE_SCHEMA.md, history is derived from borrow_records.
            #
            # NOTE: Avoid Firestore `where + order_by` here to reduce composite-index requirements.
            # For typical library sizes, client-side sort is acceptable; cap scan size defensively.
            cap = min(2000, max(int(limit) * 50, int(limit)))
            q = self._db.collection("borrow_records").where("userId", "==", user_id).limit(cap).stream()

            rows: List[Dict[str, Any]] = []
            for d in q:
                data = d.to_dict() or {}
                data.setdefault("id", d.id)
                rows.append(data)

            def _borrow_ts(row: Dict[str, Any]) -> _dt.datetime:
                bd = row.get("borrowDate")
                if isinstance(bd, _dt.datetime):
                    if bd.tzinfo is None:
                        return bd.replace(tzinfo=_dt.timezone.utc)
                    return bd.astimezone(_dt.timezone.utc)
                return _dt.datetime.min.replace(tzinfo=_dt.timezone.utc)

            rows.sort(key=_borrow_ts, reverse=True)
            return rows[: int(limit)]
        except Exception as e:  # noqa: BLE001
            logger.warning("get_user_history failed: %s", e)
            return []

    def save_user_behavior(
        self,
        user_id: str,
        event_type: str,
        payload: Optional[Dict[str, Any]] = None,
    ) -> bool:
        self._init_if_needed()
        if not self._enabled or self._db is None:
            return False

        try:
            data: Dict[str, Any] = {
                "event_type": event_type,
                "payload": payload or {},
                "ts": __import__("datetime").datetime.utcnow(),
            }
            # Not part of DATABASE_SCHEMA.md; kept as optional analytics sink.
            self._db.collection("user_history").document(user_id).collection("events").add(data)
            return True
        except Exception as e:  # noqa: BLE001
            logger.warning("save_user_behavior failed: %s", e)
            return False


_firebase_service: FirebaseService | None = None


def get_firebase_service() -> FirebaseService:
    global _firebase_service
    if _firebase_service is None:
        _firebase_service = FirebaseService()
    return _firebase_service

