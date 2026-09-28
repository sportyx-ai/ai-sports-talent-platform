"""Temporal movement metrics derived from landmark and angle timelines."""

from __future__ import annotations

from collections.abc import Sequence

import numpy as np

from app.core.models import FramePose, Landmark
from app.analysis.geometry import mean_landmark


def finite(values: Sequence[float]) -> np.ndarray:
    """Return finite values as a numeric array."""

    return np.asarray([value for value in values if np.isfinite(value)], dtype=float)


def range_summary(frames: Sequence[FramePose]) -> dict[str, dict[str, float]]:
    """Summarize minima, maxima, and ROM for all observed angle series."""

    names = {name for frame in frames for name in frame.angles}
    result: dict[str, dict[str, float]] = {}
    for name in names:
        values = finite([frame.angles.get(name, float("nan")) for frame in frames])
        if values.size:
            result[name] = {"minimum": float(values.min()), "maximum": float(values.max()),
                            "range": float(values.max() - values.min())}
    return result


def symmetry(frames: Sequence[FramePose]) -> dict[str, float]:
    """Score left/right angle agreement from 0 to 100."""

    scores: dict[str, float] = {}
    for joint in ("elbow", "shoulder", "hip", "knee", "ankle"):
        deltas = finite([
            abs(frame.angles.get(f"left_{joint}", np.nan) - frame.angles.get(f"right_{joint}", np.nan))
            for frame in frames
        ])
        if deltas.size:
            scores[joint] = float(np.clip(100 - deltas.mean() * 3, 0, 100))
    return scores


def center_of_mass_proxy(landmarks: dict[str, Landmark]) -> tuple[float, float] | None:
    """Estimate image-normalized COM from torso and hip landmarks."""

    names = ("left_shoulder", "right_shoulder", "left_hip", "right_hip")
    if not all(name in landmarks for name in names):
        return None
    center = mean_landmark([landmarks[name] for name in names])
    return center.x, center.y


def stability_and_balance(frames: Sequence[FramePose]) -> tuple[dict[str, float], dict[str, float]]:
    """Estimate stable torso motion and COM sway in image-normalized coordinates."""

    centers = [center_of_mass_proxy(frame.landmarks) for frame in frames]
    numeric = np.asarray([center for center in centers if center is not None], dtype=float)
    if len(numeric) < 3:
        return {}, {}
    sway_x, sway_y = np.std(numeric, axis=0)
    stability = float(np.clip(100 - (sway_x + sway_y) * 500, 0, 100))
    balance = float(np.clip(100 - sway_x * 700, 0, 100))
    return {"score": stability, "com_sway": float(sway_x + sway_y)}, {
        "score": balance, "lateral_com_sway": float(sway_x)
    }


def tempo(frames: Sequence[FramePose], repetitions: int) -> dict[str, float]:
    """Calculate average cadence from video duration and completed repetitions."""

    if len(frames) < 2:
        return {}
    duration = frames[-1].timestamp_seconds - frames[0].timestamp_seconds
    if duration <= 0 or repetitions <= 0:
        return {"duration_seconds": max(duration, 0.0)}
    return {"duration_seconds": duration, "reps_per_minute": repetitions / duration * 60,
            "seconds_per_rep": duration / repetitions}
