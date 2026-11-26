# KaziShift

**Shift Rota · Handover Log · Overtime Ledger**

Offline-first Flutter application for teams that need reliable shift coverage, accountable handovers and transparent overtime records when connectivity is poor.

## Features
- Weekly rota with coverage status and staff shift-swap requests.
- Handover notes with urgency, open tasks and equipment checks.
- Scheduled vs actual hours, overtime calculation and manager approvals.
- Staff and Shift Lead role modes.
- Three themes: Shift Obsidian, Daylight Roster and High-Contrast Duty.
- Hive-backed local persistence; entries are saved on-device without a network.
- Workspace JSON export and Android APK download entry point.

## Run locally
```bash
flutter doctor
flutter pub get
flutter run -d chrome
flutter run
```

## Deploy to Vercel
Import this repository into Vercel and use **Framework Preset: Other**. The included `vercel.json` runs `bash scripts/build_web.sh`, which installs Flutter stable in the build environment and runs `flutter build web --release --base-href /`. Output directory: `build/web`. First build downloads the Flutter SDK and can take longer than a normal Node build.

## Android APK
```bash
flutter build apk --release
```
APK output: `build/app/outputs/flutter-apk/app-release.apk`. GitHub Actions builds and publishes the APK as the **KaziShift Android** latest release on pushes to `main`, version tags (`v*`) and manual workflow dispatch. In-app download link: [Latest Android APK](https://github.com/kennedy-blip/kazi-shift/releases/latest/download/app-release.apk).

## Important deployment notes
This release is local-first: it does not synchronize devices or provide centralized authentication. Role switching is a local demonstration privilege mode, not a security boundary. Before payroll or regulated workforce use, add authenticated identities, server-side authorization, audited synchronization and backups.

## Layout
- `lib/models/` domain records
- `lib/storage/` Hive local persistence
- `lib/theme/` theme definitions
- `lib/screens/` feature screens
- `lib/widgets/` reusable glass UI
- `scripts/build_web.sh` Vercel Flutter web build
