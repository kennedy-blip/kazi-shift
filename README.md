# KaziShift

**Shift Rota · Handover Log · Overtime Ledger**

Offline-first Flutter application for teams that need reliable shift coverage, accountable handovers and transparent overtime records when connectivity is poor.

## Features
- Weekly rota with coverage status, role filters and shift swap requests.
- Handover notes with urgency, open tasks and equipment checks.
- Scheduled vs actual hours, overtime calculation and manager approvals.
- Staff and Shift Lead role modes; staff cannot approve or delete history.
- Three themes: Shift Obsidian, Daylight Roster and High-Contrast Duty.
- Hive-backed local persistence; entries are saved on-device without a network.
- JSON export and APK download entry point.

## Run locally
```bash
flutter doctor
flutter pub get
flutter run -d chrome
# Android
flutter run
```

## Vercel web deployment
Build command: `flutter build web --release --base-href /`
Output directory: `build/web`
Framework preset: **Other**. Vercel's standard build image does not guarantee Flutter is installed. Use a custom build image that installs Flutter stable, or build `build/web` in GitHub Actions and deploy it with the Vercel CLI. Do not use a Node/React preset.

## Android APK
```bash
flutter build apk --release
```
APK output: `build/app/outputs/flutter-apk/app-release.apk`. Push a version tag such as `git tag v1.0.0 && git push origin v1.0.0`, or run **Actions → Android APK → Run workflow**. The release workflow attaches the APK to a GitHub Release. The in-app APK Center links to the latest release; it will be available after the first workflow succeeds.

## Important deployment notes
This release is local-first: it does not synchronize devices or provide centralized authentication. Role switching is a local demonstration privilege mode, not a security boundary. Before payroll or regulated workforce use, add authenticated identities, server-side authorization, audited synchronization and backups.

## Layout
- `lib/models/` domain records
- `lib/storage/` local Hive persistence
- `lib/theme/` theme definitions
- `lib/screens/` feature screens
- `lib/widgets/` reusable glass UI
