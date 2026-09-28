"""Typed errors translated to safe HTTP responses by the API."""


class AssessmentError(Exception):
    """Base error for expected user-correctable assessment failures."""


class VideoValidationError(AssessmentError):
    """The upload cannot be safely decoded or assessed."""


class PoseExtractionError(AssessmentError):
    """No usable athlete pose could be recovered from the video."""
