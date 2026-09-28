"""Runtime compatibility checks for the pose extraction dependency."""

import mediapipe as mp
from mediapipe.tasks.python.vision.pose_landmarker import PoseLandmarker


def test_mediapipe_exposes_tasks_pose_landmarker() -> None:
    """The extraction pipeline requires the MediaPipe Tasks Pose API."""
    assert hasattr(mp, "Image")
    assert PoseLandmarker.__name__ == "PoseLandmarker"
