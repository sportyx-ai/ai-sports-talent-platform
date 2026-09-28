"""Optional OpenCV diagnostic overlay video generation."""

from __future__ import annotations

from pathlib import Path
from typing import Sequence

import cv2

from app.core.models import FramePose
from app.pose.pipeline import iter_frames


CONNECTIONS = (
    ("left_shoulder", "right_shoulder"), ("left_shoulder", "left_elbow"),
    ("left_elbow", "left_wrist"), ("right_shoulder", "right_elbow"),
    ("right_elbow", "right_wrist"), ("left_shoulder", "left_hip"),
    ("right_shoulder", "right_hip"), ("left_hip", "right_hip"), ("left_hip", "left_knee"),
    ("left_knee", "left_ankle"), ("right_hip", "right_knee"), ("right_knee", "right_ankle"),
)


def render_debug_video(
    source: Path, destination: Path, poses: Sequence[FramePose], fps: float, score: float
) -> Path:
    """Render landmarks, angle summaries, stage, and score to an MP4 artifact."""

    pose_by_index = {pose.frame_index: pose for pose in poses}
    first = next(iter_frames(source), None)
    if first is None:
        raise ValueError("Cannot render an empty video.")
    _, sample = first
    height, width = sample.shape[:2]
    destination.parent.mkdir(parents=True, exist_ok=True)
    writer = cv2.VideoWriter(str(destination), cv2.VideoWriter_fourcc(*"mp4v"), fps, (width, height))
    try:
        for index, image in iter_frames(source):
            pose = pose_by_index.get(index)
            if pose:
                for start, end in CONNECTIONS:
                    if start in pose.landmarks and end in pose.landmarks:
                        a, b = pose.landmarks[start], pose.landmarks[end]
                        cv2.line(image, (int(a.x * width), int(a.y * height)),
                                 (int(b.x * width), int(b.y * height)), (0, 255, 0), 2)
                for landmark in pose.landmarks.values():
                    cv2.circle(image, (int(landmark.x * width), int(landmark.y * height)), 3, (0, 0, 255), -1)
                text = f"Stage: {pose.stage or 'observing'}  Score: {score:.0f}"
                angle = pose.angles.get("knee_angle")
                if angle is not None:
                    text += f"  Knee: {angle:.0f}"
                cv2.putText(image, text, (15, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)
            writer.write(image)
    finally:
        writer.release()
    return destination
