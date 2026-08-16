# FoodScan – Initial API Contracts

These contracts are for Flutter ↔ Spring Boot integration.

**Primary API consumer:** Flutter mobile app.

The Next.js marketing website should **not** call scan, meal, today, history, packaged, or profile APIs in MVP.

Protected routes require `Authorization: Bearer <accessToken>`.

---

## Auth

### POST /api/v1/auth/signup

Request:

```json
{
  "email": "user@example.com",
  "password": "********"
}
```

Response: same shape as login (`accessToken` + `user`). Password min length: 6.

### POST /api/v1/auth/login

Request:

```json
{
  "email": "user@example.com",
  "password": "********"
}
```

Response:

```json
{
  "accessToken": "token",
  "user": {
    "id": "user-id",
    "email": "user@example.com"
  }
}
```

---

## Meal photo scan

### POST /api/v1/scans

Multipart:
- `image`: food image

Response:

```json
{
  "scanId": "scan-123",
  "food": {
    "name": "Paneer Butter Masala",
    "confidence": 0.92,
    "awareness": {
      "categoryKey": "paneer_curry",
      "headline": "Why this dish may be unhealthy",
      "concerns": ["Often high in saturated fat from cream and butter", "..."],
      "reduceTips": ["Ask for less cream / butter", "..."],
      "preferTips": ["Prefer grilled paneer or tomato-based gravy", "..."],
      "tip": "If you eat this, pair with salad and walk after.",
      "disclaimer": "Based on typical preparation of this dish type—not a lab analysis of your plate."
    }
  }
}
```

`awareness` may be `null` when no category rule matches. Rules are dish-category heuristics (see `IngredientAwarenessService`), not ingredient detection from the image.

### POST /api/v1/scans/{scanId}/nutrition

Request:

```json
{
  "portionGrams": 200
}
```

Optional: corrected food name if user edited detection.

Response:

```json
{
  "foodName": "Paneer Butter Masala",
  "portionGrams": 200,
  "calories": 380,
  "proteinGrams": 14,
  "carbsGrams": 12,
  "fatGrams": 30,
  "estimated": true
}
```

Nutrition estimation logic: `docs/07-calorie-and-estimation-logic.md`.

---

## Packaged food (Phase 1 barcode + Phase 2 label fallback)

### GET /api/v1/packaged/barcode/{barcode}

Path: digits-only barcode (EAN/UPC style).

Response (success): same `PackagedFoodResponse` shape (score, flags, swaps, ingredients…).

Not found → HTTP 404. Mobile offers **Photograph ingredients** fallback.

### POST /api/v1/packaged/label

Multipart:
- `image`: photo of the ingredients panel (required)
- `barcode`: optional digits if known

Flow: Spring Boot → AI `/read-label` → same rule engine as barcode.

Backend calls Open Food Facts / AI; clients must not call them directly. Rule details: `docs/07-calorie-and-estimation-logic.md` §9.

---

## Meals & daily tracking

### POST /api/v1/meals

Adds a nutrition result to today's intake.

### GET /api/v1/me/today

Returns today's calorie total, `dailyGoalKcal`, and meals.

Used by Home on load (including after Profile save) so the progress bar stays in sync.

### GET /api/v1/me/history

Returns historical calorie summaries.

---

## Profile

### GET /api/v1/me/profile

Returns user profile and goals, including:

```json
{
  "email": "user@example.com",
  "age": 30,
  "weightKg": 70,
  "heightCm": 170,
  "gender": "MALE",
  "activityLevel": "MODERATELY_ACTIVE",
  "goal": "MAINTAIN",
  "dailyGoalKcal": 2200
}
```

Enums (as persisted / returned):
- `gender`: `MALE` | `FEMALE` | `PREFER_NOT_TO_SAY` (nullable until set)
- `activityLevel`: `SEDENTARY` | `LIGHTLY_ACTIVE` | `MODERATELY_ACTIVE` | `VERY_ACTIVE`
- `goal`: `LOSE_WEIGHT` | `MAINTAIN` | `GAIN_MUSCLE`

### PUT /api/v1/me/profile

Updates profile fields. Backend recalculates and stores `dailyGoalKcal` (Mifflin–St Jeor × activity × goal adjustment; clamp 1200–4000). See `docs/07-calorie-and-estimation-logic.md`.

Request body includes age, weight, height, gender, activity level, goal (and any other allowed profile fields).

---

## AI Contract (internal)

### POST /predict

Multipart: `image`

Response:

```json
{
  "foodName": "Paneer Butter Masala",
  "confidence": 0.92
}
```

The AI service is internal and must not be exposed to clients.  
Spring Boot is the only caller of `/predict`.  
**Packaged barcode flow does not call AI** in Phase 1.
