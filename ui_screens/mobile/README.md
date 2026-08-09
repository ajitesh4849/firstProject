# FoodScan Mobile (Flutter)

Phase 1 UI-only Flutter app for FoodScan.

## Requirements

- Flutter 3.x
- Android emulator or physical device (iOS supported via Xcode on macOS)

## Run

```bash
flutter pub get
flutter run
```

## Structure

```text
lib/
├── main.dart
├── screens/     # Splash, Login, Home, Scan, Result, Portion, Nutrition, History, Profile
├── widgets/     # Shared UI (buttons, cards, bottom nav)
├── models/      # Domain models
├── services/    # MockDataService (no network)
├── routes/      # Named routes + transitions
└── utils/       # Theme + constants
```

## Notes

- Login skips real authentication and goes to Home.
- Scan uses a camera placeholder.
- Scanning simulates a short delay, then shows mock “Paneer Butter Masala”.
- Nutrition values are estimates scaled from mock per-100g macros.
