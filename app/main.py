import logging
import time
from typing import Callable

from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import router
from app.core.config import settings
from app.services.recommender import get_recommender


def _configure_logging() -> None:
    logging.basicConfig(
        level=getattr(logging, settings.log_level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
    )


_configure_logging()
logger = logging.getLogger("app")

app = FastAPI(title=settings.app_name)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def timing_middleware(request: Request, call_next: Callable[[Request], Response]):
    start = time.perf_counter()
    try:
        response = await call_next(request)
    finally:
        elapsed_ms = (time.perf_counter() - start) * 1000.0
        logger.info("%s %s -> %.1fms", request.method, request.url.path, elapsed_ms)
    return response


@app.on_event("startup")
def _startup() -> None:
    # Warm up model once at startup to ensure <200ms responses.
    try:
        get_recommender()
    except Exception as e:  # noqa: BLE001
        # Keep API up even if Firestore has no data yet.
        logger.warning("Recommender warmup skipped: %s", e)
    logger.info("Startup complete")


app.include_router(router)

