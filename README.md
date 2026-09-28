# ai-sports-talent-platform

# 🏆 Sportyx — AI Sports Talent Identification & Performance Platform

[![Spring Boot](https://img.shields.io/badge/Spring_Boot-4.0.3-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![React](https://img.shields.io/badge/React-19.2-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![MediaPipe](https://img.shields.io/badge/MediaPipe-Pose-FF6F00?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/edge/mediapipe/solutions/guide)

---

## 📌 Overview

**Sportyx** is an end-to-end, AI-powered sports talent identification and biomechanical video performance analytics platform. Built to democratize sports scouting, Sportyx allows athletes to capture smartphone videos of physical assessments, receives computer vision evaluation powered by MediaPipe and custom rule engines, and connects promising talent with sports managers, scouts, and administrators.

---

## 🏗️ System Architecture

```
                                 +------------------------------+
                                 |   Flutter Mobile App         |
                                 |  (Athlete Capture & Portal)  |
                                 +--------------+---------------+
                                                |
                                    REST APIs   | Video Uploads / Sync
                                                v
+------------------------+             +-------------------------------+
|  React Web Dashboard   | <=========> |   Spring Boot Backend Server  |
| (Admin & Manager Hub)  |  REST APIs  |       (Port 8080 / Java 21)   |
+------------------------+             +---------------+---------------+
                                                       |
                                            Async / HTTP Calls
                                                       v
                                       +-------------------------------+
                                       |   Python ML Analysis Service  |
                                       |      (Port 8000 / FastAPI)    |
                                       +-------------------------------+
```

The system comprises four core modules:
1. **`sportyx-server`**: Spring Boot 4 REST API handling authentication, event orchestration, athlete profiles, assessment storage, notifications, and manager workflows.
2. **`sportyx-ml`**: FastAPI microservice using MediaPipe Pose, OpenCV, NumPy, and SciPy for exercise rep-counting, range-of-motion (ROM) verification, technique scoring, stability analysis, and cheat detection.
3. **`sportyx-client`**: Modern React 19 web application built with Vite and Tailwind CSS v4 for administrators, talent scouts, and event organizers.
4. **`sportyx_mobile`**: Cross-platform Flutter mobile application enabling athletes to record guided biomechanical videos, upload entries, and view AI feedback.

---

## ✨ Key Features

- 🏋️ **AI Biomechanical Video Assessment**:
  - **Supported Exercises**: Squat, Push-up, Sit-up, Vertical Jump, and Standing Broad Jump.
  - **Biomechanical Metrics**: Automatic rep counting, Range of Motion (ROM), joint angle tracking, movement tempo, symmetry, and balance.
  - **Explainable Scoring**: Weighted performance score based on technique (40%), ROM (20%), consistency (15%), tempo (10%), balance (10%), and stability (5%).
- 🛡️ **Capture Quality & Integrity Checks**:
  - Detects lighting adequacy, blur, camera jitter, frame duplication, and pose coverage warnings.
- 🎯 **Talent Event Management**:
  - Admins and managers can create national or regional talent drives and fitness challenges.
- 📊 **Scout & Manager Analytics**:
  - Interactive dashboards to review leaderboards, filter top-tier talent, and access detailed biomechanical diagnostic breakdowns.
- 📱 **Seamless Mobile Video Recording**:
  - Integrated camera controls, real-time posture guidelines, and background assessment syncing.

---

## 🎨 Brand & Color Palette

Sportyx follows a cohesive purple-focused design system across all platforms:

| Token Name | Hex Code | Visual Swatch | Primary Use Case |
|------------|----------|---------------|------------------|
| **Primary Dark** | `#391053` | `██████` | Header backgrounds, dark mode containers |
| **Primary** | `#5a2675` | `██████` | Core buttons, app bars, active navigation |
| **Primary Light** | `#9d72b3` | `██████` | Secondary buttons, progress bars, highlights |
| **Accent** | `#c9a8f1` | `██████` | Badges, icons, focus states |
| **White** | `#ffffff` | `██████` | Cards, backgrounds, contrasting text |

---

## 🛠️ Technology Stack

| Layer | Technologies & Frameworks |
|-------|---------------------------|
| **Backend Server** | Java 21, Spring Boot 4.0.3, Spring Data JPA, Hibernate, H2 / PostgreSQL, Swagger UI (SpringDoc OpenAPI 2.5) |
| **ML Engine** | Python 3.11, FastAPI, Uvicorn, MediaPipe Pose 0.10, OpenCV 4.10, NumPy, SciPy, Pandas, PyTest |
| **Web Client** | React 19, Vite 7, Tailwind CSS v4, Framer Motion 12, React Router 7 |
| **Mobile App** | Flutter 3.11+, Dart, Camera API, Video Player, HTTP client |

---

## 📂 Project Directory Structure

```
ai-sports-talent-platform/
├── COLOR_PALETTE.md              # Unified UI theme & color token guidelines
├── README.md                     # Root project documentation
└── Sportyx/
    ├── sportyx-server/           # Java Spring Boot backend service
    │   ├── src/main/java/com/sportyx/backend/
    │   │   ├── Controllers/      # REST API endpoints (Events, Assessments, Athletes, etc.)
    │   │   ├── Entities/         # JPA database models
    │   │   ├── Repositories/     # Data access layer
    │   │   └── Services/         # Core business logic & ML proxy service
    │   ├── pom.xml               # Maven configuration & dependencies
    │   └── application.properties# Backend application properties
    ├── sportyx-ml/               # Python AI/ML microservice
    │   └── project/
    │       ├── app/              # FastAPI routes, pose inference & scoring engines
    │       ├── config/           # Exercise angle & rule YAML thresholds
    │       ├── tests/            # Test suite for ML pipeline
    │       └── requirements.txt  # Python package dependencies
    ├── sportyx-client/           # React 19 + Vite Web Application
    │   ├── src/                  # React pages, components, & styles
    │   ├── package.json          # Node dependencies
    │   └── tailwind.config.js    # Tailwind styling configuration
    └── sportyx_mobile/           # Flutter Mobile Application
        ├── lib/                  # Dart UI features, services, and themes
        └── pubspec.yaml          # Flutter dependencies & assets
```

---

## 🚀 Quick Start Guide

### Prerequisites
Make sure you have the following installed on your machine:
- **Java JDK 21** or later
- **Maven 3.8+** (or use included `mvnw` wrapper)
- **Python 3.11**
- **Node.js 18+** & `npm`
- **Flutter SDK 3.11+** (for mobile development)

---

### 1. Launch the Backend Server (`sportyx-server`)

```bash
cd Sportyx/sportyx-server

# Run with Maven (defaults to embedded H2 database at port 8080)
mvn spring-boot:run
```
- 🌐 **Server API URL**: `http://localhost:8080`
- 📑 **Swagger API Docs**: `http://localhost:8080/swagger-ui.html`

---

### 2. Launch the ML Microservice (`sportyx-ml`)

```bash
cd Sportyx/sportyx-ml/project

# Create & activate Python virtual environment
python -m venv .venv

# On Windows:
.venv\Scripts\activate
# On macOS/Linux:
# source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start FastAPI server on port 8000
uvicorn app.api.main:app --reload --port 8000
```
- 🌐 **ML Service URL**: `http://localhost:8000`
- 📑 **Interactive OpenAPI Docs**: `http://localhost:8000/docs`
- 🧪 **Browser Upload Interface**: `http://localhost:8000/`

---

### 3. Launch the Web Client (`sportyx-client`)

```bash
cd Sportyx/sportyx-client

# Install Node modules
npm install

# Start Vite development server
npm run dev
```
- 🌐 **Web Portal**: `http://localhost:5173`

---

### 4. Run the Mobile App (`sportyx_mobile`)

```bash
cd Sportyx/sportyx_mobile

# Fetch Flutter packages
flutter pub get

# Run on connected emulator or physical device
flutter run
```

---

## 📡 API Endpoints Overview

### Backend APIs (`sportyx-server`)
| HTTP Method | Endpoint | Description |
|-------------|----------|-------------|
| `GET` | `/api/health` | Service health status check |
| `POST` | `/api/events` | Create a new talent assessment event |
| `GET` | `/api/events` | Fetch active talent events |
| `POST` | `/api/videos/upload` | Upload athlete video & submit for ML processing |
| `GET` | `/api/assessments/{id}` | Retrieve AI assessment scores & breakdown |
| `GET` | `/api/athletes` | List registered athletes & leaderboard rankings |

### ML APIs (`sportyx-ml`)
| HTTP Method | Endpoint | Description |
|-------------|----------|-------------|
| `POST` | `/analyze` | Form upload video + exercise type -> Returns reps, ROM, stability, score, integrity report |
| `POST` | `/feedback` | Generates deterministic, natural language feedback grounded in assessment metrics |

---

## 🧪 Running Tests

### ML Service Tests
```bash
cd Sportyx/sportyx-ml/project
pytest
```

### Backend Tests
```bash
cd Sportyx/sportyx-server
mvn test
```

---

## 🤝 Contributing

1. Fork the project repository.
2. Create a feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
