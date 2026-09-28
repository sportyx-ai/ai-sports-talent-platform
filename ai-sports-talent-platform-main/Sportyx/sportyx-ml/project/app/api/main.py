"""FastAPI HTTP interface for sports video assessments."""

from __future__ import annotations

import logging
import uuid
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Annotated

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

from app.core.config import get_settings
from app.core.exceptions import AssessmentError
from app.core.logging import configure_logging
from app.core.models import AnalysisResult, ExerciseName
from app.feedback.local import FeedbackResponse, generate_local_feedback

logger = logging.getLogger(__name__)
STATIC_DIRECTORY = Path(__file__).parent / "static"


@asynccontextmanager
async def lifespan(_: FastAPI):
    """Initialize settings and process logging."""

    configure_logging()
    get_settings()
    yield


app = FastAPI(title="Sports Video Assessment API", version="1.0.0", lifespan=lifespan)
app.mount("/static", StaticFiles(directory=STATIC_DIRECTORY), name="static")


@app.exception_handler(AssessmentError)
async def assessment_error_handler(_, error: AssessmentError) -> JSONResponse:
    """Expose expected validation errors without stack traces."""
    logger.warning("Assessment error: %s", error)
    return JSONResponse(status_code=422, content={"detail": str(error)})


@app.exception_handler(Exception)
async def general_exception_handler(_, error: Exception) -> JSONResponse:
    """Log unhandled errors with stack trace and return error details."""
    logger.error("Unhandled error during assessment analysis: %s", error, exc_info=True)
    return JSONResponse(status_code=500, content={"detail": f"Server Error: {str(error)}"})


@app.get("/health")
def health() -> dict[str, str]:
    """Report liveness for local orchestration."""

    return {"status": "ok"}


@app.get("/", include_in_schema=False)
def user_interface() -> FileResponse:
    """Serve the local browser interface for testing video assessments."""

    return FileResponse(STATIC_DIRECTORY / "index.html")


@app.post("/analyze", response_model=AnalysisResult)
async def analyze(
    video: Annotated[UploadFile, File(description="A guided single-athlete video")],
    exercise: Annotated[ExerciseName | None, Form()] = None,
) -> AnalysisResult:
    """Persist a bounded upload temporarily, analyze it, then always clean it up."""

    suffix = Path(video.filename or "").suffix.lower()
    if suffix not in {".mp4", ".mov", ".avi", ".mkv", ".webm"}:
        raise HTTPException(status_code=415, detail="Upload a supported video file.")
    settings = get_settings()
    path = settings.temp_directory / f"{uuid.uuid4()}{suffix}"
    written = 0
    try:
        with path.open("wb") as target:
            while chunk := await video.read(1024 * 1024):
                written += len(chunk)
                if written > settings.max_upload_mb * 1024 * 1024:
                    raise HTTPException(status_code=413, detail="Video exceeds upload size limit.")
                target.write(chunk)
        from app.analysis.service import analyze_video

        return analyze_video(path, exercise)
    finally:
        await video.close()
        path.unlink(missing_ok=True)


@app.post("/feedback", response_model=FeedbackResponse)
def feedback(analysis: AnalysisResult) -> FeedbackResponse:
    """Create deterministic feedback grounded only in supplied analysis JSON."""

    return generate_local_feedback(analysis)
