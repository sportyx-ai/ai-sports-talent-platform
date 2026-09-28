"""Tests for MediaPipe Tasks pose extraction."""

from pathlib import Path
from types import SimpleNamespace

import numpy as np

from app.core.config import Settings
from app.pose import pipeline


class FakeImage:
    """Capture image construction without invoking MediaPipe."""

    def __init__(self, image_format: object, data: np.ndarray) -> None:
        self.image_format = image_format
        self.data = data


class FakePoseLandmarker:
    """Return a pose for every supplied video frame."""

    def __init__(self, result: object) -> None:
        self.result = result
        self.timestamps: list[int] = []

    def __enter__(self) -> "FakePoseLandmarker":
        return self

    def __exit__(self, *_: object) -> None:
        return None

    def detect_for_video(self, _: object, timestamp_ms: int) -> object:
        self.timestamps.append(timestamp_ms)
        return self.result


def test_extract_poses_uses_tasks_video_timestamps(monkeypatch) -> None:
    """Tasks results should retain landmark mapping and frame timestamps."""
    source = SimpleNamespace(x=0.1, y=0.2, z=-0.3, visibility=0.9, presence=0.8)
    result = SimpleNamespace(pose_landmarks=[[source] * len(pipeline.LANDMARK_NAMES)])
    detector = FakePoseLandmarker(result)
    settings = Settings(pose_model_path=Path("unused.task"))

    monkeypatch.setattr(
        pipeline,
        "mp",
        SimpleNamespace(Image=FakeImage, ImageFormat=SimpleNamespace(SRGB="srgb")),
    )
    monkeypatch.setattr(pipeline, "create_pose_landmarker", lambda _: detector)
    monkeypatch.setattr(
        pipeline,
        "video_metadata",
        lambda *_: pipeline.VideoMetadata(fps=20.0, frame_count=2, width=4, height=4),
    )
    monkeypatch.setattr(
        pipeline,
        "iter_frames",
        lambda _: iter([(0, np.zeros((4, 4, 3), dtype=np.uint8)), (1, np.zeros((4, 4, 3), dtype=np.uint8))]),
    )

    frames, metadata = pipeline.extract_poses(Path("exercise.mp4"), settings)

    assert metadata.fps == 20.0
    assert detector.timestamps == [0, 50]
    assert len(frames) == 2
    assert frames[0].landmarks["nose"].visibility == 0.9
    assert frames[0].landmarks["nose"].presence == 0.8
