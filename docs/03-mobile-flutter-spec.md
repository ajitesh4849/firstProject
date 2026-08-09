# FoodScan – Mobile Flutter UI Specification

## Role

Flutter is the **primary FoodScan product** (Android + iOS).

The Next.js site is marketing only and does not replace these screens.

## Technology

- Flutter
- Dart
- Material 3
- Android + iOS
- Use responsive layouts where practical
- UI first; backend/AI integration later

## Suggested Flutter Structure

```text
ui_screens/mobile/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── login/
│   │   │   └── login_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── scan/
│   │   │   ├── scan_screen.dart
│   │   │   └── scanning_screen.dart
│   │   ├── result/
│   │   │   └── food_result_screen.dart
│   │   ├── portion/
│   │   │   └── portion_screen.dart
│   │   ├── nutrition/
│   │   │   └── nutrition_screen.dart
│   │   ├── history/
│   │   │   └── history_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   ├── widgets/
│   ├── models/
│   ├── services/
│   ├── routes/
│   └── utils/
└── pubspec.yaml
```

## Screen 1 – Splash

Layout:

```text
[ APP LOGO ]

FoodScan
Scan food. Know calories. Eat smarter.

[ Get Started ]
```

Get Started → Login.

## Screen 2 – Login

```text
FoodScan

[ Email / Phone ]
[ Password ]

[ Login ]

[ Continue with Google ]
```

For UI phase, login can navigate to Home without real authentication.

## Screen 3 – Home / Today

```text
Today

1850 / 2200 kcal
[ progress ]

Breakfast       450 kcal
Lunch           680 kcal
Dinner          720 kcal

             [ + Scan Food ]

Home     History     Profile
```

Requirements:
- Daily calorie summary
- Progress indicator
- Meal list
- Primary scan CTA
- Bottom navigation

## Screen 4 – Scan

```text
[ Camera Preview ]

[ Scan Food ]

Point camera at your food
```

For the first UI version, use a camera placeholder. Real camera integration comes later.

## Screen 5 – Scanning

```text
[ Food Image / Placeholder ]

Detecting food...
Estimating calories...

[ Loading ]
```

For UI-only phase, use a short simulated delay and navigate to Food Result.

## Screen 6 – Food Result

```text
[ Food Image ]

Paneer Butter Masala
Confidence: 92%

[ Looks Correct ]
[ Edit Food Name ]
```

Edit can initially show an editable field/dialog.

## Screen 7 – Portion

```text
Select Portion

( ) Small     100g
(•) Medium    200g
( ) Large     300g

Custom grams [______]

[ Continue ]
```

The selected portion must be passed to Nutrition Result.

## Screen 8 – Nutrition

```text
380 kcal

Protein   14g
Carbs     12g
Fat       30g

[ Add to Today ]
[ Scan Another ]
```

Show a small disclaimer:
“Estimated nutrition values.”

## Screen 9 – History

```text
History

[ Calendar ]

Mon   1900 kcal
Tue   2100 kcal
Wed   1750 kcal

Weekly average
```

UI-only calendar can use mock data.

## Screen 10 – Profile / Goals

```text
Profile

Age       [ 30 ]
Weight    [ 70 kg ]
Height    [ 170 cm ]

Goal
(•) Lose Weight
( ) Maintain
( ) Gain Muscle

[ Save ]
```

Do not calculate medical recommendations yet.

## Navigation

```text
Splash
  ↓
Login
  ↓
Home
  ↓
Scan
  ↓
Scanning
  ↓
Food Result
  ↓
Portion
  ↓
Nutrition
  ↓
Home

Home ↔ History
Home ↔ Profile
```

## UI Rules

- Reusable primary button
- Reusable cards
- Consistent spacing
- Accessible text contrast
- Avoid hard-coded screen dimensions
- Keep screen widgets focused on presentation
- Put reusable widgets in `widgets/`
- Put navigation in `routes/`
- Do not add backend dependencies during the UI-only phase
