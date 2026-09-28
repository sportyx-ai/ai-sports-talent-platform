# Sports Video Assessment Module

An explainable FastAPI service that assesses guided, single-athlete smartphone videos using MediaPipe Pose and configurable two-dimensional coaching rules. It supports squat, push-up, sit-up, vertical jump, and standing broad jump.

## Important limits

This is a coaching-assistance system, not a certified biomechanics, identity, anti-doping, or medical system. A single uncalibrated RGB camera cannot reliably measure physical distance, depth in world units, identity, edited-video provenance, or all 3D joint motion. The service reports confidence and evidence-based warnings instead of treating unavailable measurements as passes.

For best results, record one athlete with the entire body visible, adequate lighting, a static camera, and an exercise-appropriate side or front view. The API accepts guided-but-flexible recordings and will warn or reject unsuitable captures.

## Installation

Requires Python 3.11.

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.api.main:app --reload
```

Open `http://127.0.0.1:8000/` for the browser upload interface or `http://127.0.0.1:8000/docs` for interactive API documentation. On Linux/macOS, activate the virtual environment with `source .venv/bin/activate`.

The browser UI previews a selected video, submits it to `/analyze`, requests local coaching feedback, and displays the score, repetitions, capture decision, warnings, and raw JSON response. It is intended for local testing and does not retain uploads after analysis.

## API

`POST /analyze` accepts `multipart/form-data`:

```bash
curl -X POST http://127.0.0.1:8000/analyze -F "video=@squat.mp4" -F "exercise=squat"
```

`exercise` is optional. When supplied, the service uses it as the requested rule profile and includes detection confidence. The result includes the requested core fields: exercise, repetition totals, ROM, joint-angle summaries, tempo, symmetry, stability, balance, cheating/capture report, score, strengths, and weaknesses. It additionally returns confidence, detailed repetitions, validation findings, and warnings.

`POST /feedback` accepts a prior analysis JSON and returns deterministic, grounded assessment text:

```bash
curl -X POST http://127.0.0.1:8000/feedback -H "Content-Type: application/json" -d @analysis.json
```

No video is sent to any LLM. The default feedback provider is local and template-based, so it cannot invent a score or measurement. A future external provider should implement the same JSON-only boundary.

## Architecture

```
app/
  api/            FastAPI routes and upload lifecycle
  core/           settings, errors, logging, Pydantic contracts
  pose/           OpenCV decode, MediaPipe inference, smoothing
  analysis/       geometry, temporal metrics, orchestration
  exercises/      detector extension interface and rule engine
  cheating/       explainable integrity/quality checks
  scoring/        weighted score aggregation
  feedback/       deterministic grounded response generator
  visualization/  optional annotated debug MP4 renderer
config/           rule thresholds and capture-quality policy
tests/            unit and API contract tests
```

`analysis.service.analyze_video` orchestrates the pipeline: stream validation → MediaPipe landmarks → confidence-gated smoothing → angles and movement metrics → exercise/rep rules → integrity evidence → weighted score.

## Rules and scoring

`config/exercises.yaml` contains all exercise thresholds. It defines a primary angle, flexion/extension bounds, required ROM, phase duration, and exercise-specific rules. The detector uses smoothed angle extrema, peak prominence, hysteresis-like bounds, and minimum phase duration to form a rep. Each cycle is valid only when its applicable rules pass.

Default weights are technique 40%, range of motion 20%, consistency 15%, tempo 10%, balance 10%, and stability 5%. They can be overridden through configuration. Missing or low-confidence visibility reduces assessment confidence rather than being scored as compliant.

Standing broad-jump distance is deliberately not inferred. The response sets `manual_measurement_required`; record distance externally until a visible calibration marker/mat protocol is adopted.

## Capture integrity

The system checks pose coverage, body visibility, blur, lighting, duplicate-frame patterns, and abrupt temporal/camera motion. Each check returns a decision, confidence, reason, and evidence. The global policy in `config/quality_policy.yaml` controls pass/warn/reject thresholds.

Face identity, person switching, robust replay detection, multi-person detection, and forensic tamper proof cannot be asserted from MediaPipe Pose alone. They are marked `not_verifiable` by default; connect an approved person/face detector and provenance service through dedicated adapters before using those claims in a high-stakes setting.

## Debug visualization

`app.visualization.debug_video.render_debug_video` can render an MP4 with skeleton, selected knee angle, movement stage, and score. Keep this disabled in production unless artifact retention and access control are configured.

## Configuration and safety

Copy `.env.example` to `.env` to set upload limits. Uploads are streamed to a temporary directory, bounded by size and duration, and deleted after analysis. Do not expose the service publicly without authentication, rate limiting, malware scanning, and secure artifact storage.

## Tests

```bash
pytest
```

Tests cover geometric primitives, score aggregation, local feedback grounding, and basic HTTP validation. Add anonymized, consented exercise fixtures and calibration studies before tuning rules for a target population.

## Future work

- Validate thresholds against sports-science protocols and labeled cohort data.
- Add a capture app with camera-placement guidance and a calibration mat.
- Add a multi-person detector, optional face-consistency provider with consent, and signed capture provenance.
- Train a temporal classifier behind the `ExerciseDetector` interface.
- Add authenticated persistence, metrics, model/version tracking, and fairness evaluation across body types, clothing, and lighting conditions.
