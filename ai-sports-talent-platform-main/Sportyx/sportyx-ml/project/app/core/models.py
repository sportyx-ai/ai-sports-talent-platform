"""Versioned domain models shared by the API and analysis pipeline."""

from __future__ import annotations

from enum import StrEnum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class ExerciseName(StrEnum):
    """Exercises currently supported by the rule-based pipeline."""

    SQUAT = "squat"
    PUSH_UP = "push_up"
    SIT_UP = "sit_up"
    VERTICAL_JUMP = "vertical_jump"
    STANDING_BROAD_JUMP = "standing_broad_jump"
    UNKNOWN = "unknown"


class PolicyDecision(StrEnum):
    """Capture integrity policy outcome."""

    PASS = "pass"
    WARN = "warn"
    REJECT = "reject"
    NOT_VERIFIABLE = "not_verifiable"


class Landmark(BaseModel):
    """A normalized pose point for one video frame."""

    x: float
    y: float
    z: float = 0.0
    visibility: float = 0.0
    presence: float | None = None


class FramePose(BaseModel):
    """Pose and derived measurements for one decoded frame."""

    frame_index: int
    timestamp_seconds: float
    landmarks: dict[str, Landmark] = Field(default_factory=dict)
    angles: dict[str, float] = Field(default_factory=dict)
    stage: str | None = None
    warnings: list[str] = Field(default_factory=list)


class Finding(BaseModel):
    """An explainable validation finding."""

    code: str
    message: str
    severity: str = "warning"
    frame_start: int | None = None
    frame_end: int | None = None
    value: float | None = None
    threshold: float | None = None


class Repetition(BaseModel):
    """A detected movement cycle and its rule evaluation."""

    index: int
    frame_start: int
    frame_peak: int
    frame_end: int
    valid: bool
    findings: list[Finding] = Field(default_factory=list)


class IntegrityCheck(BaseModel):
    """Evidence and decision emitted by a capture-integrity check."""

    name: str
    decision: PolicyDecision
    confidence: float = Field(ge=0.0, le=1.0)
    reason: str
    evidence: dict[str, Any] = Field(default_factory=dict)


class CheatingReport(BaseModel):
    """Capture-quality and anti-cheating assessment."""

    detected: bool = False
    reason: str = ""
    decision: PolicyDecision = PolicyDecision.PASS
    checks: list[IntegrityCheck] = Field(default_factory=list)


class ScoreReport(BaseModel):
    """Weighted assessment score and grounded coaching signals."""

    overall_score: float = Field(ge=0.0, le=100.0)
    subscores: dict[str, float] = Field(default_factory=dict)
    strengths: list[str] = Field(default_factory=list)
    weaknesses: list[str] = Field(default_factory=list)


class AnalysisResult(BaseModel):
    """Stable, serializable result returned from `/analyze`."""

    model_config = ConfigDict(use_enum_values=True)

    schema_version: str = "1.0"
    exercise: ExerciseName = ExerciseName.UNKNOWN
    exercise_confidence: float = Field(default=0.0, ge=0.0, le=1.0)
    analysis_confidence: float = Field(default=0.0, ge=0.0, le=1.0)
    frame_count: int = 0
    duration_seconds: float = 0.0
    total_reps: int = 0
    valid_reps: int = 0
    invalid_reps: int = 0
    range_of_motion: dict[str, dict[str, float]] = Field(default_factory=dict)
    joint_angles: dict[str, dict[str, float]] = Field(default_factory=dict)
    tempo: dict[str, float] = Field(default_factory=dict)
    symmetry: dict[str, float] = Field(default_factory=dict)
    stability: dict[str, float] = Field(default_factory=dict)
    balance: dict[str, float] = Field(default_factory=dict)
    body_alignment: dict[str, float] = Field(default_factory=dict)
    center_of_mass: dict[str, float] = Field(default_factory=dict)
    repetitions: list[Repetition] = Field(default_factory=list)
    validation_findings: list[Finding] = Field(default_factory=list)
    cheating: CheatingReport = Field(default_factory=CheatingReport)
    overall_score: float = Field(default=0.0, ge=0.0, le=100.0)
    subscores: dict[str, float] = Field(default_factory=dict)
    strengths: list[str] = Field(default_factory=list)
    weaknesses: list[str] = Field(default_factory=list)
    manual_measurement_required: bool = False
    warnings: list[str] = Field(default_factory=list)
