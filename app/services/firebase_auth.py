from __future__ import annotations

from typing import Optional

from fastapi import HTTPException

from app.services.firebase_service import get_firebase_service


def verify_firebase_id_token(id_token: str) -> dict:
    if not id_token:
        raise HTTPException(status_code=401, detail="Missing Authorization bearer token")

    fb = get_firebase_service()
    fb.ensure_initialized()
    if not fb.active:
        raise HTTPException(status_code=503, detail="Firebase is not available")

    try:
        import firebase_admin.auth as firebase_auth  # type: ignore

        return firebase_auth.verify_id_token(id_token)
    except Exception as e:  # noqa: BLE001
        raise HTTPException(status_code=401, detail="Invalid Firebase ID token") from e


def uid_from_claims(claims: dict) -> str:
    uid = claims.get("uid") or claims.get("user_id") or claims.get("sub")
    if not uid:
        raise HTTPException(status_code=401, detail="Token missing uid")
    return str(uid)


def parse_bearer_authorization(authorization: Optional[str]) -> Optional[str]:
    if not authorization:
        return None
    parts = authorization.split(" ", 1)
    if len(parts) != 2:
        return None
    scheme, token = parts[0].strip(), parts[1].strip()
    if scheme.lower() != "bearer" or not token:
        return None
    return token
