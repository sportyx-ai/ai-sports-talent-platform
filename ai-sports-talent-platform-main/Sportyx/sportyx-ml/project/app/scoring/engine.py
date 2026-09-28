"""Weighted, configuration-driven performance score aggregation."""

from __future__ import annotations

from collections.abc import Sequence

import numpy as np

from app.core.config import load_yaml_config
from app.core.models import Repetition, ScoreReport


def score_assessment(
    repetitions: Sequence[Repetition], rom: dict[str, dict[str, float]], symmetry: dict[str, float],
    stability: dict[str, float], balance: dict[str, float], tempo: dict[str, float]
) -> ScoreReport:
    """Combine evidence into transparent weighted subscores and coaching signals."""

    weights = load_yaml_config("exercises.yaml")["scoring_weights"]
    total = len(repetitions)
    valid = sum(rep.valid for rep in repetitions)
    technique = 100 * valid / total if total else 0.0
    primary_rom = max((entry["range"] for entry in rom.values()), default=0.0)
    range_score = float(np.clip(primary_rom / 80 * 100, 0, 100))
    consistency = _consistency(repetitions)
    tempo_score = _tempo_score(tempo)
    subscores = {
        "technique": technique, "range_of_motion": range_score, "consistency": consistency,
        "tempo": tempo_score, "balance": balance.get("score", 0.0),
        "stability": stability.get("score", 0.0),
    }
    overall = sum(subscores[name] * weights[name] for name in weights)
    strengths = [f"{name.replace('_', ' ')} is strong ({score:.0f}/100)." for name, score in subscores.items()
                 if score >= 80]
    weaknesses = [f"Improve {name.replace('_', ' ')} ({score:.0f}/100)." for name, score in subscores.items()
                  if score < 60]
    if symmetry and np.mean(list(symmetry.values())) < 65:
        weaknesses.append("Left/right joint motion is noticeably asymmetric.")
    return ScoreReport(overall_score=round(float(overall), 1),
                       subscores={name: round(float(score), 1) for name, score in subscores.items()},
                       strengths=strengths, weaknesses=weaknesses)


def _consistency(repetitions: Sequence[Repetition]) -> float:
    """Score variation in detected rep duration."""

    if len(repetitions) < 2:
        return 70.0 if repetitions else 0.0
    durations = np.asarray([rep.frame_end - rep.frame_start for rep in repetitions], dtype=float)
    return float(np.clip(100 - np.std(durations) / max(np.mean(durations), 1) * 200, 0, 100))


def _tempo_score(tempo: dict[str, float]) -> float:
    """Reward a controlled, practical movement cadence."""

    seconds = tempo.get("seconds_per_rep")
    if seconds is None:
        return 0.0
    return float(np.clip(100 - abs(seconds - 2.5) * 25, 0, 100))
