import os
from dataclasses import dataclass


def _default_firebase_credential_path() -> str | None:
    env = os.getenv("FIREBASE_CREDENTIAL_PATH")
    if env:
        return env

    # Common local dev path: project root/serviceAccountKey.json
    candidate = os.path.join(os.getcwd(), "serviceAccountKey.json")
    return candidate if os.path.exists(candidate) else None


def _default_firebase_enabled(credential_path: str | None) -> bool:
    env = os.getenv("FIREBASE_ENABLED")
    if env is not None:
        return env.strip().lower() in {"1", "true", "yes", "y"}
    return credential_path is not None


@dataclass(frozen=True)
class Settings:
    # API
    app_name: str = os.getenv("APP_NAME", "ai-library-system")
    environment: str = os.getenv("ENVIRONMENT", "development")
    log_level: str = os.getenv("LOG_LEVEL", "INFO")

    # Data
    books_csv_path: str = os.getenv("BOOKS_CSV_PATH", os.path.join("app", "data", "books.csv"))

    # Firebase (optional)
    firebase_credential_path: str | None = _default_firebase_credential_path()
    firebase_enabled: bool = _default_firebase_enabled(firebase_credential_path)
    firebase_app_name: str = os.getenv("FIREBASE_APP_NAME", "default")

    # Recommender refresh (Firestore continuous updates)
    recommender_refresh_ttl_seconds: int = int(os.getenv("RECOMMENDER_REFRESH_TTL_SECONDS", "60"))

    # Personalized ranking / reranking
    recommend_candidate_pool: int = int(os.getenv("RECOMMEND_CANDIDATE_POOL", "50"))
    recommend_max_per_category: int = int(os.getenv("RECOMMEND_MAX_PER_CATEGORY", "2"))
    recommend_returned_half_life_days: int = int(os.getenv("RECOMMEND_RETURNED_HALF_LIFE_DAYS", "180"))

    # Auth
    # DEV ONLY: allow calling user-personalized endpoints without Bearer token (uses X-Dev-Uid header).
    dev_auth_bypass: bool = os.getenv("DEV_AUTH_BYPASS", "false").strip().lower() in {"1", "true", "yes", "y"}


settings = Settings()

