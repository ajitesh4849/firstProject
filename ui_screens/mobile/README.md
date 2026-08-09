# FoodScan Mobile (Flutter)

Enterprise-ready Flutter client for FoodScan (Android / iOS).

## Requirements

- Flutter 3.x
- Android emulator / device, or iOS via Xcode on macOS

## Run

```bash
flutter pub get
flutter run
```

Android emulator API base URL defaults to `http://10.0.2.2:8080`.

Override:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080
```

## UI system

- Typography: Plus Jakarta Sans
- Tokens: colors, spacing, radii, shadows in `lib/utils/app_theme.dart`
- Shared components: buttons, cards, section headers, empty/error/loading states, bottom nav
- Portrait lock, system UI styling, accessible text scaling clamp

## Notes

- Backend (8080) and AI (8000) must be running for the full scan flow
- Camera / gallery permissions are configured for Android + iOS
