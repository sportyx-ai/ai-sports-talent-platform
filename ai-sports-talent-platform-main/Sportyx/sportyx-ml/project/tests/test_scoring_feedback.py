"""Tests for scoring and deterministic feedback grounding."""

from app.core.models import AnalysisResult, ExerciseName, Repetition
from app.feedback.local import generate_local_feedback
from app.scoring.engine import score_assessment


def test_score_uses_configured_weights() -> None:
    """A valid rep and healthy supporting metrics should produce a positive score."""

    score = score_assessment(
        [Repetition(index=1, frame_start=0, frame_peak=5, frame_end=10, valid=True)],
        {"knee_angle": {"range": 80}}, {"knee": 90}, {"score": 90}, {"score": 90},
        {"seconds_per_rep": 2.5},
    )
    assert score.overall_score > 80


def test_feedback_only_reports_supplied_values() -> None:
    """Local feedback must echo the supplied score and repetition counts."""

    result = AnalysisResult(exercise=ExerciseName.SQUAT, overall_score=72, total_reps=3, valid_reps=2)
    feedback = generate_local_feedback(result)
    assert "72/100" in feedback.overall_assessment
    assert "2 valid of 3" in feedback.overall_assessment
