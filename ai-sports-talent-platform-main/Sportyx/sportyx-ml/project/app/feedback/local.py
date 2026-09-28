"""Deterministic, field-grounded feedback generation with no external LLM."""

from __future__ import annotations

from pydantic import BaseModel, Field

from app.core.models import AnalysisResult


class FeedbackResponse(BaseModel):
    """Safe local coaching response for a completed analysis."""

    overall_assessment: str
    strengths: list[str] = Field(default_factory=list)
    weaknesses: list[str] = Field(default_factory=list)
    coaching_advice: list[str] = Field(default_factory=list)
    injury_prevention_advice: list[str] = Field(default_factory=list)
    motivational_message: str


def generate_local_feedback(result: AnalysisResult) -> FeedbackResponse:
    """Render feedback exclusively from explicitly available analysis fields."""

    exercise = result.exercise.replace("_", " ")
    assessment = (
        f"{exercise.title()} assessment: {result.overall_score:.0f}/100 overall score "
        f"from {result.valid_reps} valid of {result.total_reps} detected repetitions."
    )
    coaching = list(result.weaknesses[:3])
    if result.cheating.decision != "pass":
        coaching.append("Address the recording-quality warnings before relying on this assessment.")
    if not coaching:
        coaching.append("Keep repeating the same controlled movement pattern.")
    safety = ["Stop if you feel pain; this video assessment is not medical advice."]
    if result.stability.get("score", 100) < 60:
        safety.append("Use a clear, non-slip surface and prioritize controlled balance.")
    return FeedbackResponse(
        overall_assessment=assessment, strengths=result.strengths,
        weaknesses=result.weaknesses, coaching_advice=coaching,
        injury_prevention_advice=safety,
        motivational_message="Use these observations to guide your next deliberate practice session.",
    )
