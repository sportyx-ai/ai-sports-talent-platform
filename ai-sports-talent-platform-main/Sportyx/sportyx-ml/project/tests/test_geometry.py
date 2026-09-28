"""Unit tests for reusable landmark geometry."""

from app.analysis.geometry import angle_at, derived_angles
from app.core.models import Landmark


def landmark(x: float, y: float) -> Landmark:
    """Build a visible test landmark."""

    return Landmark(x=x, y=y, visibility=1.0)


def test_angle_at_returns_right_angle() -> None:
    """A perpendicular joint must calculate to ninety degrees."""

    assert angle_at(landmark(1, 0), landmark(0, 0), landmark(0, 1)) == 90.0


def test_derived_angles_contains_elbow_average() -> None:
    """Bilateral elbow angles should produce the canonical aggregate."""

    landmarks = {
        "left_shoulder": landmark(1, 0), "left_elbow": landmark(0, 0), "left_wrist": landmark(0, 1),
        "right_shoulder": landmark(1, 0), "right_elbow": landmark(0, 0), "right_wrist": landmark(0, 1),
    }
    assert derived_angles(landmarks)["elbow_angle"] == 90.0
