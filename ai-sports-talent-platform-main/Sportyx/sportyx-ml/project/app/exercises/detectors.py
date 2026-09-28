"""Configurable rule-based exercise recognition, repetition counting, and validation."""

from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import Sequence

import numpy as np
from scipy.signal import find_peaks

from app.core.config import exercise_profile
from app.core.models import ExerciseName, Finding, FramePose, Repetition


class ExerciseDetector(ABC):
    """Stable extension point for rule-based and learned exercise classifiers."""

    name: ExerciseName

    @abstractmethod
    def analyze(self, frames: Sequence[FramePose], fps: float) -> list[Repetition]:
        """Detect and validate movement cycles."""


class AngleCycleDetector(ExerciseDetector):
    """Detect flexion-extension cycles using extrema and configured hysteresis."""

    def __init__(self, name: ExerciseName) -> None:
        self.name = name
        self.profile = exercise_profile(name.value)

    def analyze(self, frames: Sequence[FramePose], fps: float) -> list[Repetition]:
        """Return valid and invalid configured angle cycles."""

        key = self.profile["primary_angle"]
        values = np.asarray([frame.angles.get(key, np.nan) for frame in frames], dtype=float)
        valid_indices = np.flatnonzero(np.isfinite(values))
        if len(valid_indices) < 3:
            return []
        interpolated = np.interp(np.arange(len(values)), valid_indices, values[valid_indices])
        minimum_distance = max(1, int(self.profile.get("min_phase_seconds", 0.25) * fps * 2))
        troughs, _ = find_peaks(-interpolated, distance=minimum_distance,
                                prominence=max(5.0, self.profile["minimum_rom"] * 0.25))
        repetitions: list[Repetition] = []
        for number, trough in enumerate(troughs, start=1):
            before = np.flatnonzero(interpolated[:trough] >= self.profile["extension_angle"])
            after = np.flatnonzero(interpolated[trough + 1:] >= self.profile["extension_angle"])
            if not len(before) or not len(after):
                continue
            start, end = int(before[-1]), int(trough + 1 + after[0])
            findings = self._validate_cycle(frames, start, int(trough), end, interpolated, fps)
            repetitions.append(Repetition(index=number, frame_start=start, frame_peak=int(trough),
                                          frame_end=end, valid=not any(
                                              finding.severity == "error" for finding in findings
                                          ), findings=findings))
        return repetitions

    def _validate_cycle(
        self, frames: Sequence[FramePose], start: int, trough: int, end: int,
        values: np.ndarray, fps: float
    ) -> list[Finding]:
        """Validate generic ROM plus exercise-specific biomechanics."""

        cycle = values[start:end + 1]
        findings: list[Finding] = []
        rom = float(np.max(cycle) - np.min(cycle))
        if rom < self.profile["minimum_rom"]:
            findings.append(Finding(code="insufficient_range_of_motion", severity="error",
                                    message="Movement range did not meet the configured minimum.",
                                    frame_start=start, frame_end=end, value=rom,
                                    threshold=self.profile["minimum_rom"]))
        minimum = float(np.min(cycle))
        rules = self.profile.get("rules", {})
        depth_limit = rules.get("minimum_depth_angle", rules.get("minimum_flexion_angle",
                                rules.get("minimum_crouch_angle")))
        if depth_limit is not None and minimum > depth_limit:
            findings.append(Finding(code="insufficient_depth", severity="error",
                                    message="The flexion phase was not deep enough.", frame_start=start,
                                    frame_end=end, value=minimum, threshold=depth_limit))
        if self.name is ExerciseName.SQUAT:
            trunk = np.nanmax([frame.angles.get("torso_inclination", np.nan) for frame in frames[start:end + 1]])
            if np.isfinite(trunk) and trunk > rules["maximum_trunk_inclination"]:
                findings.append(Finding(code="excessive_trunk_lean", severity="error",
                                        message="Keep the torso more upright.",
                                        value=float(trunk), threshold=rules["maximum_trunk_inclination"]))
        elif self.name is ExerciseName.PUSH_UP:
            hips = np.asarray([frame.angles.get("hip_angle", np.nan) for frame in frames[start:end + 1]])
            deviation = float(np.nanmean(abs(hips - 180))) if np.isfinite(hips).any() else 0.0
            if deviation > rules["maximum_body_line_deviation"]:
                findings.append(Finding(code="body_line_deviation", severity="error",
                                        message="Avoid hip sagging or piking.",
                                        value=deviation, threshold=rules["maximum_body_line_deviation"]))
        elif self.name is ExerciseName.SIT_UP:
            velocity = np.abs(np.diff(cycle)) * fps
            if len(velocity) and float(np.max(velocity)) > rules["max_angular_velocity"]:
                findings.append(Finding(code="excessive_momentum", severity="error",
                                        message="Use a more controlled sit-up.",
                                        value=float(np.max(velocity)), threshold=rules["max_angular_velocity"]))
        return findings


def available_detectors() -> dict[ExerciseName, ExerciseDetector]:
    """Create detector instances for all supported rule-based exercises."""

    return {name: AngleCycleDetector(name) for name in ExerciseName if name is not ExerciseName.UNKNOWN}


def detect_exercise(frames: Sequence[FramePose]) -> tuple[ExerciseName, float]:
    """Select the configured exercise with the strongest compatible primary-angle motion."""

    candidates: list[tuple[ExerciseName, float]] = []
    for name, detector in available_detectors().items():
        profile = detector.profile
        values = np.asarray([frame.angles.get(profile["primary_angle"], np.nan) for frame in frames])
        values = values[np.isfinite(values)]
        if values.size < 3:
            continue
        movement = float(values.max() - values.min())
        compatibility = movement / max(profile["minimum_rom"], 1)
        candidates.append((name, min(1.0, compatibility)))
    if not candidates:
        return ExerciseName.UNKNOWN, 0.0
    name, confidence = max(candidates, key=lambda item: item[1])
    return (name, confidence) if confidence >= 0.55 else (ExerciseName.UNKNOWN, confidence)
