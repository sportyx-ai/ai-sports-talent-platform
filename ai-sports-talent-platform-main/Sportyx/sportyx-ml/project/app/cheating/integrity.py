"""Explainable capture-integrity and video-quality checks."""

from __future__ import annotations

from pathlib import Path
from typing import Sequence

import cv2
import numpy as np

from app.core.config import load_yaml_config
from app.core.models import CheatingReport, FramePose, IntegrityCheck, PolicyDecision
from app.pose.pipeline import iter_frames


def _decision(value: float, limit: float, reject: bool = False) -> PolicyDecision:
    """Map a threshold measurement to an integrity policy decision."""

    if value > limit:
        return PolicyDecision.REJECT if reject else PolicyDecision.WARN
    return PolicyDecision.PASS


def assess_integrity(path: Path, frames: Sequence[FramePose]) -> CheatingReport:
    """Assess quality and discontinuity evidence without making identity claims."""

    policy = load_yaml_config("quality_policy.yaml")
    checks = [
        _pose_coverage(frames, policy),
        _out_of_frame(frames, policy),
        _visual_quality(path, policy),
        _temporal_integrity(path, policy),
        IntegrityCheck(name="face_consistency", decision=PolicyDecision.NOT_VERIFIABLE, confidence=0.0,
                       reason="Face identity cannot be established from pose-only analysis."),
        IntegrityCheck(name="multiple_people", decision=PolicyDecision.NOT_VERIFIABLE, confidence=0.0,
                       reason="Multi-person detection requires an optional person detector."),
    ]
    rejected = [check for check in checks if check.decision is PolicyDecision.REJECT]
    warnings = [check for check in checks if check.decision is PolicyDecision.WARN]
    decision = PolicyDecision.REJECT if rejected else (PolicyDecision.WARN if warnings else PolicyDecision.PASS)
    reasons = [check.reason for check in rejected or warnings]
    return CheatingReport(detected=bool(rejected), reason="; ".join(reasons), decision=decision, checks=checks)


def _pose_coverage(frames: Sequence[FramePose], policy: dict) -> IntegrityCheck:
    coverage = sum(bool(frame.landmarks) for frame in frames) / max(len(frames), 1)
    decision = _decision(1 - coverage, 1 - policy["minimum_pose_coverage"], reject=True)
    return IntegrityCheck(name="pose_coverage", decision=decision, confidence=coverage,
                          reason="Pose coverage is sufficient." if decision is PolicyDecision.PASS
                          else "Primary athlete is not consistently visible.",
                          evidence={"coverage": coverage})


def _out_of_frame(frames: Sequence[FramePose], policy: dict) -> IntegrityCheck:
    required = ("left_shoulder", "right_shoulder", "left_hip", "right_hip", "left_ankle", "right_ankle")
    failures = [frame for frame in frames if any(
        name not in frame.landmarks or frame.landmarks[name].visibility < 0.5 for name in required
    )]
    ratio = len(failures) / max(len(frames), 1)
    decision = _decision(ratio, policy["maximum_out_of_frame_fraction"], reject=ratio > 0.65)
    return IntegrityCheck(name="body_visibility", decision=decision, confidence=1 - ratio,
                          reason="Full-body coverage is adequate." if decision is PolicyDecision.PASS
                          else "Body landmarks are out of frame or occluded too often.",
                          evidence={"affected_frame_fraction": ratio})


def _visual_quality(path: Path, policy: dict) -> IntegrityCheck:
    blur_count = dark_count = total = 0
    for index, frame in iter_frames(path):
        if index % 5:
            continue
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        blur_count += int(cv2.Laplacian(gray, cv2.CV_64F).var() < 35)
        dark_count += int(gray.mean() < 45)
        total += 1
    blur = blur_count / max(total, 1)
    dark = dark_count / max(total, 1)
    value = max(blur / policy["maximum_blur_fraction"], dark / policy["maximum_dark_fraction"])
    decision = _decision(value, 1.0)
    return IntegrityCheck(name="lighting_and_blur", decision=decision, confidence=max(0.0, 1 - value),
                          reason="Lighting and sharpness are adequate." if decision is PolicyDecision.PASS
                          else "Low light or motion blur limits reliable assessment.",
                          evidence={"blur_fraction": blur, "dark_fraction": dark})


def _temporal_integrity(path: Path, policy: dict) -> IntegrityCheck:
    previous: np.ndarray | None = None
    duplicate = camera_motion = total = 0
    for index, frame in iter_frames(path):
        if index % 3:
            continue
        gray = cv2.resize(cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY), (160, 90))
        if previous is not None:
            difference = float(np.mean(cv2.absdiff(gray, previous)))
            duplicate += int(difference < 0.5)
            camera_motion += int(difference > policy["maximum_camera_motion"])
            total += 1
        previous = gray
    duplicate_ratio = duplicate / max(total, 1)
    motion_ratio = camera_motion / max(total, 1)
    value = max(duplicate_ratio / policy["maximum_duplicate_frame_fraction"], motion_ratio / 0.5)
    decision = _decision(value, 1.0)
    return IntegrityCheck(name="temporal_integrity", decision=decision, confidence=max(0.0, 1 - value),
                          reason="No strong temporal discontinuity was found." if decision is PolicyDecision.PASS
                          else "Frame duplication, abrupt motion, or camera movement was detected.",
                          evidence={"duplicate_fraction": duplicate_ratio, "high_motion_fraction": motion_ratio})
