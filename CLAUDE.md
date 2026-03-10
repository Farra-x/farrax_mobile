# Farrax Mobile — Claude Code Project Context

## 🐄 What is Farrax?
Farrax is a cattle herd management mobile app targeting Irish and UK farmers.
This repo is the **Flutter Android app** only.
The backend server lives at: https://github.com/Farra-x/farrax_server

## 🏗️ This Repo
- **Repo:** https://github.com/Farra-x/farrax_mobile
- **Stack:** Flutter (Dart), Android-first, iOS later
- **State:** Riverpod
- **Local DB:** SQLite via Drift (offline-first)
- **HTTP:** Dio
- **Navigation:** go_router
- **Auth:** JWT stored in flutter_secure_storage

## 📁 Structure (`lib/`)
```
core/
  database/     ← Drift DB, DAOs, tables
  api/          ← Dio client, interceptors, endpoints
  constants/    ← App constants, tag formats, breeds
  utils/        ← Validators, formatters, helpers
features/
  animals/      ← Animal profiles, EID scanner
    data/       ← Repository impl, data sources
    domain/     ← Models, repository interfaces, use cases
    presentation/ ← Screens, widgets, providers
  records/      ← Birth, death, movement events
  health/       ← Medicine, TB tests, withdrawal periods
  movements/    ← In/out movement tracking
  auth/         ← Login, registration, token management
shared/
  widgets/      ← Reusable UI components
  theme/        ← App theme, colors, text styles
```

## 🇮🇪 Irish/UK Cattle Rules — CRITICAL
- **Irish tag format:** IE + 12 digits (e.g. IE141123456789)
- **UK tag format:** UK + 12 digits (e.g. UK123456789012)
- **Registration deadline:** Within 27 days of birth (Ireland)
- **Movement reporting:** Within 7 days ICBF (Ireland), 3 days BCMS (UK)
- **Required calf reg fields:** tag number, DOB, sex, breed, dam tag, sire tag

## 🎨 UI Style
- Primary: #1A7A3C (Farrax green)
- Accent: #F0A500 (amber/gold)
- Background: #F5F7F5
- Material Design 3
- Large touch targets (48x48dp min) — farmers use with gloves
- Full dark mode support

## ⚙️ Conventions
- All dates stored as ISO 8601 in SQLite
- Tag numbers stored UPPERCASE, no spaces
- Offline-first: writes go to SQLite first, sync when online
- Feature folders use clean architecture: data / domain / presentation
- Riverpod providers in `presentation/providers/` per feature
- API base URL from env: `FARRAX_API_URL` (default: http://10.0.2.2:8000)
- Never use `var` — always explicit types or `final`
- Never make API calls from widgets — use providers
- Never use `print()` — use the logger utility
- JWT tokens in flutter_secure_storage only (never SharedPreferences)

## 🔗 Server API Base
- Local dev: http://10.0.2.2:8000  (Android emulator → PC localhost)
- Production: set via FARRAX_API_URL env variable

## 📝 Adding a New Feature
1. Domain model in `features/{name}/domain/models/`
2. Drift table in `core/database/tables/`
3. Repository interface in `features/{name}/domain/repositories/`
4. Repository impl in `features/{name}/data/`
5. Riverpod provider in `features/{name}/presentation/providers/`
6. Screen in `features/{name}/presentation/screens/`

## 🧪 Testing
- `flutter test` — unit + widget tests
- Tests mirror lib structure in `test/`
