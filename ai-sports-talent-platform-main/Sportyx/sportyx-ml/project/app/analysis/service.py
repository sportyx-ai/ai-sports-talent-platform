"""Orchestrates pose extraction, exercise rules, integrity checks, and scoring."""

from __future__ import annotations

from pathlib import Path

import numpy as np

from app.analysis.metrics import range_summary, stability_and_balance, symmetry, tempo
from app.cheating.integrity import assess_integrity
from app.core.config import get_settings
from app.core.models import AnalysisResult, ExerciseName
from app.exercises.detectors import available_detectors, detect_exercise
from app.pose.pipeline import extract_poses
from app.scoring.engine import score_assessment


def analyze_video(path: Path, requested_exercise: ExerciseName | None = None) -> AnalysisResult:
    """Produce a complete explainable assessment for a validated local video."""

    frames, metadata = extract_poses(path, get_settings())
    detected, confidence = detect_exercise(frames)
    exercise = requested_exercise or detected
    repetitions = available_detectors()[exercise].analyze(frames, metadata.fps) if exercise != ExerciseName.UNKNOWN else []
    for repetition in repetitions:
        for index in range(repetition.frame_start, min(repetition.frame_end + 1, len(frames))):
            frames[index].stage = "valid_rep" if repetition.valid else "invalid_rep"
    rom = range_summary(frames)
    symmetry_scores = symmetry(frames)
    stability, balance = stability_and_balance(frames)
    tempo_metrics = tempo(frames, len(repetitions))
    integrity = assess_integrity(path, frames)
    score = score_assessment(repetitions, rom, symmetry_scores, stability, balance, tempo_metrics)
    coverage = sum(bool(frame.landmarks) for frame in frames) / max(len(frames), 1)
    findings = [finding for repetition in repetitions for finding in repetition.findings]
    warnings = [check.reason for check in integrity.checks if check.decision.value in {"warn", "reject"}]
    return AnalysisResult(
        exercise=exercise, exercise_confidence=confidence if not requested_exercise else min(confidence, 0.9),
        analysis_confidence=round(float(np.clip(coverage * (0.7 if integrity.detected else 1.0), 0, 1)), 2),
        frame_count=metadata.frame_count, duration_seconds=round(metadata.duration_seconds, 3),
        total_reps=len(repetitions), valid_reps=sum(rep.valid for rep in repetitions),
        invalid_reps=sum(not rep.valid for rep in repetitions), range_of_motion=rom,
        joint_angles=rom, tempo=tempo_metrics, symmetry=symmetry_scores, stability=stability,
        balance=balance, repetitions=repetitions, validation_findings=findings, cheating=integrity,
        overall_score=score.overall_score, subscores=score.subscores, strengths=score.strengths,
        weaknesses=score.weaknesses, manual_measurement_required=exercise is ExerciseName.STANDING_BROAD_JUMP,
        warnings=warnings,
    )
