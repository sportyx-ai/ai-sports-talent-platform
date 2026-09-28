"""Landmark geometry primitives used by every exercise detector."""

from __future__ import annotations

from collections.abc import Iterable
from typing import Mapping

import numpy as np

from app.core.models import Landmark


def point(landmark: Landmark) -> np.ndarray:
    """Convert a landmark to a three-dimensional numeric vector."""

    return np.array([landmark.x, landmark.y, landmark.z], dtype=float)


def angle_at(a: Landmark, vertex: Landmark, c: Landmark) -> float:
    """Return the unsigned angle ABC in degrees, safely handling degeneracy."""

    first, second = point(a) - point(vertex), point(c) - point(vertex)
    norm = np.linalg.norm(first) * np.linalg.norm(second)
    if norm < 1e-9:
        return float("nan")
    cosine = float(np.clip(np.dot(first, second) / norm, -1.0, 1.0))
    return float(np.degrees(np.arccos(cosine)))


def inclination(a: Landmark, b: Landmark, vertical: bool = True) -> float:
    """Return unsigned segment inclination relative to vertical or horizontal."""

    delta = point(b)[:2] - point(a)[:2]
    if np.linalg.norm(delta) < 1e-9:
        return float("nan")
    reference = np.array([0.0, 1.0] if vertical else [1.0, 0.0])
    cosine = float(np.clip(abs(np.dot(delta, reference)) / np.linalg.norm(delta), -1.0, 1.0))
    return float(np.degrees(np.arccos(cosine)))


def mean_landmark(landmarks: Iterable[Landmark]) -> Landmark:
    """Return the coordinate mean of one or more landmarks."""

    entries = list(landmarks)
    if not entries:
        raise ValueError("At least one landmark is required")
    values = np.array([[item.x, item.y, item.z, item.visibility] for item in entries])
    return Landmark(x=float(values[:, 0].mean()), y=float(values[:, 1].mean()),
                    z=float(values[:, 2].mean()), visibility=float(values[:, 3].mean()))


def has_visible(landmarks: Mapping[str, Landmark], names: Iterable[str], threshold: float) -> bool:
    """Return whether every named landmark is available and visible."""

    return all(name in landmarks and landmarks[name].visibility >= threshold for name in names)


def angle_if_visible(
    landmarks: Mapping[str, Landmark], names: tuple[str, str, str], threshold: float
) -> float:
    """Calculate a landmark angle only when all required points are reliable."""

    if not has_visible(landmarks, names, threshold):
        return float("nan")
    return angle_at(*(landmarks[name] for name in names))


def derived_angles(landmarks: Mapping[str, Landmark], threshold: float = 0.5) -> dict[str, float]:
    """Calculate canonical bilateral joint and posture angles."""

    output: dict[str, float] = {}
    for side in ("left", "right"):
        output[f"{side}_elbow"] = angle_if_visible(
            landmarks, (f"{side}_shoulder", f"{side}_elbow", f"{side}_wrist"), threshold
        )
        output[f"{side}_shoulder"] = angle_if_visible(
            landmarks, (f"{side}_elbow", f"{side}_shoulder", f"{side}_hip"), threshold
        )
        output[f"{side}_hip"] = angle_if_visible(
            landmarks, (f"{side}_shoulder", f"{side}_hip", f"{side}_knee"), threshold
        )
        output[f"{side}_knee"] = angle_if_visible(
            landmarks, (f"{side}_hip", f"{side}_knee", f"{side}_ankle"), threshold
        )
        output[f"{side}_ankle"] = angle_if_visible(
            landmarks, (f"{side}_knee", f"{side}_ankle", f"{side}_foot_index"), threshold
        )
    pairs = {"elbow": ("left_elbow", "right_elbow"), "shoulder": ("left_shoulder", "right_shoulder"),
             "hip": ("left_hip", "right_hip"), "knee": ("left_knee", "right_knee"),
             "ankle": ("left_ankle", "right_ankle")}
    for name, keys in pairs.items():
        values = [output[key] for key in keys if np.isfinite(output[key])]
        output[f"{name}_angle"] = float(np.mean(values)) if values else float("nan")
    if has_visible(landmarks, ("left_shoulder", "right_shoulder", "left_hip", "right_hip"), threshold):
        shoulders = mean_landmark([landmarks["left_shoulder"], landmarks["right_shoulder"]])
        hips = mean_landmark([landmarks["left_hip"], landmarks["right_hip"]])
        output["torso_inclination"] = inclination(hips, shoulders, vertical=True)
        output["back_inclination"] = output["torso_inclination"]
    if has_visible(landmarks, ("nose", "left_shoulder", "right_shoulder"), threshold):
        shoulders = mean_landmark([landmarks["left_shoulder"], landmarks["right_shoulder"]])
        output["head_inclination"] = inclination(shoulders, landmarks["nose"], vertical=True)
    return output
