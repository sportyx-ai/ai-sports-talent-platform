"""Streaming OpenCV/MediaPipe pose extraction with landmark smoothing."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

import cv2
import numpy as np

from app.analysis.geometry import derived_angles
from app.core.config import Settings
from app.core.exceptions import PoseExtractionError, VideoValidationError
from app.core.models import FramePose, Landmark

try:
    import mediapipe as mp
except ImportError:
    mp = None


@dataclass(frozen=True)
class VideoMetadata:
    """Safe metadata read from an uploaded video."""

    fps: float
    frame_count: int
    width: int
    height: int

    @property
    def duration_seconds(self) -> float:
        """Return nominal duration derived from frame count."""

        return self.frame_count / self.fps if self.fps else 0.0


LANDMARK_NAMES = (
    "nose", "left_eye_inner", "left_eye", "left_eye_outer", "right_eye_inner", "right_eye",
    "right_eye_outer", "left_ear", "right_ear", "mouth_left", "mouth_right", "left_shoulder",
    "right_shoulder", "left_elbow", "right_elbow", "left_wrist", "right_wrist", "left_pinky",
    "right_pinky", "left_index", "right_index", "left_thumb", "right_thumb", "left_hip",
    "right_hip", "left_knee", "right_knee", "left_ankle", "right_ankle", "left_heel",
    "right_heel", "left_foot_index", "right_foot_index",
)


def video_metadata(path: Path, settings: Settings) -> VideoMetadata:
    """Open a video and validate its basic decodability and resource limits."""

    capture = cv2.VideoCapture(str(path))
    if not capture.isOpened():
        raise VideoValidationError("Unable to decode the uploaded video.")
    try:
        fps = float(capture.get(cv2.CAP_PROP_FPS))
        count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
        metadata = VideoMetadata(fps=fps, frame_count=count,
                                 width=int(capture.get(cv2.CAP_PROP_FRAME_WIDTH)),
                                 height=int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT)))
    finally:
        capture.release()
    if fps <= 0 or fps > settings.max_fps or count <= 0:
        raise VideoValidationError("Video has unsupported FPS or no frames.")
    if metadata.duration_seconds > settings.max_duration_seconds:
        raise VideoValidationError(f"Video exceeds {settings.max_duration_seconds:g} second limit.")
    return metadata


def iter_frames(path: Path) -> Iterator[tuple[int, np.ndarray]]:
    """Yield BGR frames without retaining the whole upload in memory."""

    capture = cv2.VideoCapture(str(path))
    try:
        index = 0
        while True:
            valid, frame = capture.read()
            if not valid:
                break
            yield index, frame
            index += 1
    finally:
        capture.release()


def create_pose_landmarker(model_path: Path):
    """Create a single-person MediaPipe Tasks pose detector for video frames."""
    if mp is None:
        raise PoseExtractionError("MediaPipe is not installed.")
    if not model_path.is_file():
        raise PoseExtractionError(
            f"Pose model is unavailable at {model_path}. "
            "Install the bundled pose_landmarker_lite.task model."
        )
    try:
        from mediapipe.tasks.python.core.base_options import BaseOptions
        from mediapipe.tasks.python.vision.core.vision_task_running_mode import VisionTaskRunningMode
        from mediapipe.tasks.python.vision.pose_landmarker import PoseLandmarker, PoseLandmarkerOptions

        options = PoseLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=str(model_path)),
            running_mode=VisionTaskRunningMode.VIDEO,
            num_poses=1,
            min_pose_detection_confidence=0.5,
            min_pose_presence_confidence=0.5,
            min_tracking_confidence=0.5,
        )
        return PoseLandmarker.create_from_options(options)
    except (RuntimeError, ValueError, OSError) as error:
        raise PoseExtractionError(f"Unable to initialize the pose model: {error}") from error


def extract_poses(path: Path, settings: Settings) -> tuple[list[FramePose], VideoMetadata]:
    """Run MediaPipe Pose on every frame and return smoothed normalized landmarks."""

    metadata = video_metadata(path, settings)
    frames: list[FramePose] = []
    with create_pose_landmarker(settings.pose_model_path) as pose:
        for index, bgr in iter_frames(path):
            rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
            image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
            timestamp_ms = round(index * 1000 / metadata.fps)
            result = pose.detect_for_video(image, timestamp_ms)
            landmarks: dict[str, Landmark] = {}
            if result.pose_landmarks:
                for name, source in zip(LANDMARK_NAMES, result.pose_landmarks[0], strict=True):
                    landmarks[name] = Landmark(
                        x=source.x,
                        y=source.y,
                        z=source.z,
                        visibility=source.visibility or 0.0,
                        presence=source.presence,
                    )
            frame = FramePose(frame_index=index, timestamp_seconds=index / metadata.fps, landmarks=landmarks)
            frame.angles = derived_angles(landmarks, settings.min_landmark_visibility)
            frames.append(frame)
    if not any(frame.landmarks for frame in frames):
        raise PoseExtractionError("No athlete pose was detected. Ensure the full body is visible.")
    return smooth_poses(frames, settings.min_landmark_visibility), metadata


def smooth_poses(frames: list[FramePose], visibility_threshold: float) -> list[FramePose]:
    """Apply confidence-gated exponential smoothing independently per landmark."""

    previous: dict[str, np.ndarray] = {}
    alpha = 0.35
    for frame in frames:
        for name, landmark in frame.landmarks.items():
            current = np.array([landmark.x, landmark.y, landmark.z], dtype=float)
            if landmark.visibility >= visibility_threshold and name in previous:
                current = alpha * current + (1 - alpha) * previous[name]
            if landmark.visibility >= visibility_threshold:
                previous[name] = current
            landmark.x, landmark.y, landmark.z = map(float, current)
        frame.angles = derived_angles(frame.landmarks, visibility_threshold)
    return frames
