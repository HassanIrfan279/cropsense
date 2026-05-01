# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CropSense is a Pakistan Smart Farm Intelligence Platform — a Flutter/FastAPI application providing AI-powered agricultural insights. The app covers 36 districts across 4 provinces, with Grok AI advisory, ML yield prediction, and offline-first caching.

## Development Commands

### Backend (FastAPI)
```bash
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --port 8000
# API docs at http://localhost:8000/docs
```

### Frontend (Flutter)
```bash
flutter pub get
flutter run -d chrome          # Web (primary target)
flutter run -d windows         # Windows desktop
flutter build web --release    # Output: build/web/
```

### Code Generation (after changing Freezed models or adding JSON serialization)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Train ML Model
```bash
cd backend
python train_model.py          # Outputs model files to backend/models/
```

## Architecture

### Stack
- **Frontend**: Flutter 3.x (Dart), targeting web and Windows desktop
- **Backend**: FastAPI + Uvicorn on port 8000, deployed to Render.com
- **State**: Riverpod 3.0 (`AsyncNotifier` pattern throughout)
- **Cache**: Hive (IndexedDB on web, file-based on desktop) — 6–24 hr freshness window
- **AI**: Grok API via `backend/app/services/grok.py`
- **ML**: scikit-learn RandomForest for yield prediction (`backend/app/services/predictor.py`)

### Request Flow
```
Flutter Screen → Riverpod Provider → ApiService (Dio) → FastAPI backend → Grok API / ML model
                                          ↓
                                   Hive cache (offline fallback)
```

### Frontend Structure
- `lib/main.dart` — entry point: loads `.env`, initializes Hive, wraps app in `ProviderScope`
- `lib/app.dart` — GoRouter config (6 routes) and responsive shell (nav rail on desktop, drawer on mobile)
- `lib/screens/` — one folder per screen: `dashboard/`, `map/`, `analytics/`, `ai_advisor/`, `crop_calendar/`, `reports/`
- `lib/data/models/` — Freezed immutable data classes with JSON serialization
- `lib/data/services/` — `api_service.dart` (Dio HTTP) and `cache_service.dart` (Hive)
- `lib/providers/` — Riverpod providers connecting services to screens
- `lib/core/constants.dart` — district list, crop types, symptom labels (English & Roman Urdu)

### Backend Structure
- `backend/app/main.py` — FastAPI app, CORS config, router registration
- `backend/app/routes/` — 5 route files: `districts.py`, `yield_data.py`, `risk_map.py`, `ai_advise.py`, `stats.py`
- `backend/app/services/grok.py` — Grok API client for agricultural advisory
- `backend/app/services/predictor.py` — loads trained sklearn model and scaler from `backend/models/`
- `backend/database.py` and `backend/app/models/orm_models.py` — Oracle DB stubs (not yet wired into routes; routes use mock data)

### Key Data Models (Freezed)
All models in `lib/data/models/` are immutable with `.copyWith()` and `fromJson`/`toJson`. The main ones: `AIAdvice`, `AIAdviceRequest`, `District`, `YieldData`, `RiskMap`, `StatsModel`.

## Environment Variables

**Frontend** (`.env` in root):
```
CROPSENSE_API_URL=https://cropsense-apl.onrender.com/
GROK_API_KEY=...
APP_VERSION=1.0.0
```

**Backend** (`backend/.env`):
```
ORACLE_USER=system
ORACLE_PASSWORD=...
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_SERVICE=XEPDB1
GROK_API_KEY=...
CORS_ORIGINS=http://localhost:8080,...
```

## API Endpoints

| Route | Method | Description |
|-------|--------|-------------|
| `/api/districts` | GET | All 36 districts with current sensor readings |
| `/api/provinces` | GET | 4-province summary stats |
| `/api/risk-map` | GET | National risk levels per district |
| `/api/yield/{district}/{crop}` | GET | Historical yield + climate (2005–2023) |
| `/api/ndvi-timeseries/{district}` | GET | NDVI vegetation index over time |
| `/api/stats/{district}` | GET | Statistical analysis by crop |
| `/api/predict` | POST | ML yield prediction from field conditions |
| `/api/ai-advise` | POST | Grok AI agricultural advisory |
| `/health` | GET | Health check |

## Key Patterns

- **Riverpod**: All providers use `AsyncNotifier` or `FutureProvider`; screens consume via `ref.watch`. Don't use `StateNotifier` (deprecated pattern in this codebase).
- **Freezed models**: Run `build_runner` after any model change. Generated files (`*.freezed.dart`, `*.g.dart`) are committed.
- **Responsive layout**: Breakpoints at 800px (compact) and 1200px (wide); `LayoutBuilder` used in screens to switch nav rail vs drawer.
- **Offline-first**: `cache_service.dart` wraps all API calls — always check cache before fetching; update cache on success.
- **Theme**: Green color scheme (`#1B5E20` primary, `#8BC34A` accent) defined in `lib/core/theme.dart`. Material 3 enabled.

## Known Limitations

- Oracle DB is configured but **routes use hardcoded mock data** — the ORM layer is a stub.
- No tests exist (`test/` directory is empty).
- CORS in `main.py` allows all origins — tighten for production.
