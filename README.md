# 🐄 Farrax Mobile

> Flutter cattle management app for Irish & UK farmers.

[![Flutter CI](https://github.com/Farra-x/farrax_mobile/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/Farra-x/farrax_mobile/actions)

**Server repo:** https://github.com/Farra-x/farrax_server

## Quick Start
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Stack
- Flutter + Dart (Android first)
- Riverpod (state), Drift/SQLite (offline), Dio (HTTP), go_router (nav)

## MVP Features
- [ ] EID Tag Scanning
- [ ] Calf Registration (IE/UK tag format)
- [ ] Dam-Sire Parentage Linking
- [ ] Birth / Death / Movement Records
- [ ] Medicine Cabinet + Withdrawal Tracking
- [ ] TB Test Recording
- [ ] ICBF / AIM Integration
