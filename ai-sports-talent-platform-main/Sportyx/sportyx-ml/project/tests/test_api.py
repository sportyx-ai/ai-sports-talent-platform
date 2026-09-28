"""API contract tests not requiring a video inference runtime."""

from fastapi.testclient import TestClient

from app.api.main import app
from app.core.exceptions import PoseExtractionError


def test_health() -> None:
    """Health endpoint should be available for deployment checks."""

    response = TestClient(app).get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_user_interface_is_served() -> None:
    """Root endpoint should serve the browser upload interface."""

    response = TestClient(app).get("/")
    assert response.status_code == 200
    assert "Sports Video Assessment" in response.text


def test_analyze_rejects_non_video_upload() -> None:
    """Upload endpoint should reject unsupported media before processing."""

    response = TestClient(app).post("/analyze", files={"video": ("notes.txt", b"hello", "text/plain")})
    assert response.status_code == 415


def test_analyze_returns_json_for_pose_failure(monkeypatch) -> None:
    """Expected pose runtime failures should not become HTML 500 responses."""
    from app.analysis import service

    def fail(*_: object) -> None:
        raise PoseExtractionError("Pose model is unavailable.")

    monkeypatch.setattr(service, "analyze_video", fail)
    response = TestClient(app).post("/analyze", files={"video": ("exercise.mp4", b"video", "video/mp4")})

    assert response.status_code == 422
    assert response.json() == {"detail": "Pose model is unavailable."}
