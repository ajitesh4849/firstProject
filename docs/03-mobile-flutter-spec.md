# FoodScan – Mobile Flutter UI Specification

## Role

Flutter is the **primary FoodScan product** (Android + iOS).

The Next.js site is marketing only and does not replace these screens.

## Technology

- Flutter / Dart / Material 3
- Android + iOS
- Camera + gallery (`image_picker`)
- Barcode (`mobile_scanner`)
- JWT session (`shared_preferences`)
- HTTP client to Spring Boot (`API_BASE_URL` via `--dart-define`)

## Suggested Flutter Structure

```text
ui_screens/mobile/
├── android/
├── ios/
├── lib/
│   ├── main.dart                 # loadSession() then runApp
│   ├── screens/
│   │   ├── splash/
│   │   ├── login/
│   │   ├── home/
│   │   ├── scan/
│   │   │   ├── scan_screen.dart           # Meal photo | Packaged toggle
│   │   │   └── scanning_screen.dart
│   │   ├── packaged/
│   │   │   ├── packaged_barcode_screen.dart
│   │   │   └── packaged_result_screen.dart
│   │   ├── result/
│   │   │   └── food_result_screen.dart    # + IngredientAwarenessCard
│   │   ├── portion/
│   │   ├── nutrition/
│   │   ├── history/
│   │   └── profile/
│   ├── widgets/
│   │   └── ingredient_awareness_card.dart
│   ├── models/
│   ├── services/
│   │   ├── api_client.dart                # JWT, 401 → Login
│   │   └── daily_calorie_goal_calculator.dart  # preview only; server saves goal
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_navigator.dart             # rootNavigatorKey for 401 redirect
│   └── utils/
└── pubspec.yaml
```

## Screen 1 – Splash

Centered logo + title + tagline.

Behavior:
1. If no token → Login
2. If token → `GET /api/v1/me/profile`
   - success → Home
   - 401 → clear session → Login

No “Get Started” gate once session exists.

## Screen 2 – Login / Signup

Email + password. Calls `POST /api/v1/auth/login` or signup. On success stores JWT and goes to Home.

## Screen 3 – Home / Today

```text
Today

1850 / 2200 kcal
[ progress ]

Breakfast       450 kcal
...

             [ + Scan Food ]

Home     History     Profile
```

- Loads `GET /api/v1/me/today` on appear (also when returning from Profile so goal updates).
- Progress uses `caloriesConsumed` / `dailyGoalKcal`.

## Screen 4 – Scan

Mode toggle: **Meal photo** | **Packaged**.

### Meal photo
- Camera preview / gallery pick
- Primary CTA: Scan Food
- Empty state: soft surface + copy (“Point at a plated meal…”) — not a black void

### Packaged
- Explains barcode scan
- CTA → Packaged barcode screen

## Screen 5 – Scanning

Meal-only. Shows processing while `POST /api/v1/scans` runs, then Food Result.

## Screen 6 – Food Result

```text
[ Food Image ]

Paneer Butter Masala
Confidence: 92%

[ Ingredient awareness card ]
  Why this dish may be unhealthy
  What to reduce / prefer
  Tip
  Disclaimer: typical preparation, not lab analysis

[ Looks Correct ]
[ Edit Food Name ]   ← bottom sheet (not dialog) for keyboard-safe edit
```

Rename refreshes local awareness rules from the new name when possible.

## Screen 7 – Portion

Preset Small / Medium / Large + custom grams. Keyboard-safe layout (scroll + viewInsets).

## Screen 8 – Nutrition

Macros + Add to Today / Scan Another. Disclaimer: estimated values.

## Screen 9 – Packaged barcode

- Live barcode camera (`mobile_scanner`)
- Or enter digits manually
- Calls `GET /api/v1/packaged/barcode/{code}`
- On success → Packaged result

## Screen 10 – Packaged result

```text
Product name
Brand · barcode
Score: BETTER | OK | CAUTION

Nutrition (per 100g if available)
Flags (E-numbers, sugar/salt, MSG, hydrogenated fats, …)
Healthier swaps
Disclaimer: educational, not medical advice
```

No calorie add-to-today in Phase 1 (awareness only).

## Screen 11 – History

Day summaries from `GET /api/v1/me/history`.

## Screen 12 – Profile / Goals

```text
Age / Weight / Height
Gender          (Male | Female | Prefer not to say)
Activity level  (Sedentary … Very active)
Goal            (Lose | Maintain | Gain)

Suggested daily target (preview) → saved as dailyGoalKcal on Save

[ Save ]
[ Log out ]
```

Save → `PUT /api/v1/me/profile` (backend recalculates `dailyGoalKcal`).

Log out → clear JWT → Login.

## Navigation

```text
Splash ──(valid token)──→ Home
  └──(no/invalid)──→ Login → Home

Home → Scan
  ├─ Meal photo → Scanning → Food Result → Portion → Nutrition → Home
  └─ Packaged → Barcode → Packaged Result → (back)

Home ↔ History
Home ↔ Profile → Log out → Login
```

## Session / API client rules

- Attach `Authorization: Bearer <token>` on protected calls
- On **401**, clear session and navigate to Login via root navigator
- Physical device: `API_BASE_URL` must be the **backend host LAN IP** (Docker machine), not localhost

## UI Rules

- Reusable primary button / consistent spacing
- Accessible contrast
- Avoid hard-coded screen dimensions; respect keyboard insets on forms
- Prefer bottom sheets for edits that need keyboard
- Keep presentation in screens; API in `services/`
- Cards allowed for interactive result blocks (awareness, packaged flags)
