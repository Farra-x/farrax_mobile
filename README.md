# 🐄 Farrax — Cattle Management App

> Smart herd management for Irish & UK farmers. Built with Flutter + FastAPI.

[![Flutter CI](https://github.com/Farra-x/farrax_mobile/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/Farra-x/farrax_mobile/actions)
[![Server CI](https://github.com/Farra-x/farrax_mobile/actions/workflows/server_ci.yml/badge.svg)](https://github.com/Farra-x/farrax_mobile/actions)

## 📁 Project Structure

```
farrax/
├── app/          # Flutter Android app
├── server/       # Python FastAPI backend
├── docs/         # Documentation
└── .github/      # CI/CD workflows
```

## 🚀 Quick Start

### Flutter App
```bash
cd app
flutter pub get
flutter run
```

### Python Server
```bash
cd server
python -m venv venv
venv\Scripts\activate      # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## 🔗 Key Links
- API Docs: http://localhost:8000/docs
- ICBF: https://www.icbf.com
- DAFM AIM: https://agfood.agriculture.gov.ie

## 📋 Features (MVP)
- [x] Project setup
- [ ] EID Tag Scanning
- [ ] Calf Registration
- [ ] Dam-Sire Parentage- [ ] Birth / Death / Movement Records
- [ ] Medicine Cabinet
- [ ] TB Test Recording
- [ ] Withdrawal Period Tracking
- [ ] ICBF / AIM Integration
