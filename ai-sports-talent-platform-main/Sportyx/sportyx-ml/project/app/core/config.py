"""Application settings and YAML-backed assessment configuration."""

from __future__ import annotations

from functools import lru_cache
import os
from pathlib import Path
from typing import Any

import yaml
from pydantic import Field
from pydantic import BaseModel


ROOT_DIR = Path(__file__).resolve().parents[2]


def _load_dotenv() -> None:
    """Load simple KEY=VALUE entries from a local .env without overriding environment."""

    dotenv = ROOT_DIR / ".env"
    if not dotenv.exists():
        return
    for line in dotenv.read_text(encoding="utf-8").splitlines():
        key, separator, value = line.strip().partition("=")
        if separator and key and not key.startswith("#"):
            os.environ.setdefault(key, value.strip().strip("'\""))


class Settings(BaseModel):
    """Environment configurable operational limits."""

    max_upload_mb: int = Field(default=200, ge=1)
    max_duration_seconds: float = Field(default=120.0, gt=1)
    max_fps: float = Field(default=60.0, gt=1)
    min_landmark_visibility: float = Field(default=0.5, ge=0, le=1)
    temp_directory: Path = ROOT_DIR / ".runtime"
    pose_model_path: Path = ROOT_DIR / "config" / "models" / "pose_landmarker_lite.task"
    debug_artifacts: bool = False


@lru_cache
def get_settings() -> Settings:
    """Return cached process settings."""

    _load_dotenv()
    values = {
        "max_upload_mb": os.getenv("SVA_MAX_UPLOAD_MB"),
        "max_duration_seconds": os.getenv("SVA_MAX_DURATION_SECONDS"),
        "max_fps": os.getenv("SVA_MAX_FPS"),
        "min_landmark_visibility": os.getenv("SVA_MIN_LANDMARK_VISIBILITY"),
        "pose_model_path": os.getenv("SVA_POSE_MODEL_PATH"),
        "debug_artifacts": os.getenv("SVA_DEBUG_ARTIFACTS"),
    }
    settings = Settings(**{name: value for name, value in values.items() if value is not None})
    settings.temp_directory.mkdir(parents=True, exist_ok=True)
    return settings


@lru_cache
def load_yaml_config(filename: str) -> dict[str, Any]:
    """Load a bundled YAML configuration document."""

    with (ROOT_DIR / "config" / filename).open(encoding="utf-8") as stream:
        data = yaml.safe_load(stream)
    return data if isinstance(data, dict) else {}


def exercise_profile(exercise: str) -> dict[str, Any]:
    """Return the rule profile for an exercise."""

    return load_yaml_config("exercises.yaml").get("exercises", {}).get(exercise, {})
