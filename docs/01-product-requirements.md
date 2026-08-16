# FoodScan – Product Requirements

## 1. Product

FoodScan is a food-scanning and calorie-tracking application.

**Primary product:** Flutter mobile app (Android + iOS).

**Public website:** Marketing and SEO only. It explains the product; it does not replace the mobile tracker in MVP.

Core user journeys (mobile):

1. **Meal photo:** Scan food → identify food → confirm food (+ ingredient awareness) → select portion → estimate calories/nutrition → add to daily intake → track history.
2. **Packaged food:** Scan barcode → look up product → rule-based risk flags + healthier swaps (no AI in Phase 1).

## 2. Platforms

### Mobile (primary)
Flutter/Dart application targeting:
- Android
- iOS

Owns the full authenticated user journey: login/session, scan (meal + packaged), portion, nutrition, today/history, profile/goals.

### Public Website (marketing only)
React + Next.js + TypeScript.

Purpose:
- Product marketing
- SEO
- Explain features
- Pricing (placeholder OK)
- About
- Contact
- Privacy
- Terms
- Drive installs / interest in the mobile app

Out of scope for MVP website:
- Login / signup
- Dashboard / daily calories
- Image upload / scan
- Meal history
- Profile editing
- Payments

If a browser-based authenticated tracker is needed later, add it as a **separate** client — do not turn the marketing site into the app.

### Backend
Java + Spring Boot REST API.

Owns auth/JWT, profile calorie-goal calculation, meal scan orchestration, nutrition estimation, packaged barcode analysis (Open Food Facts + rules), persistence.

### AI
Python + FastAPI service for **meal photo** food recognition/inference.

Clients never call the AI service directly.

**Packaged Phase 1 does not use AI** (barcode + Open Food Facts + rule engine). AI may be used later for OCR / unlisted products / deeper label explanation.

## 3. Initial MVP

### Mobile
1. Splash (session gate: saved JWT → Home, else Login)
2. Login / Signup
3. Home/Today (daily consumed vs `dailyGoalKcal`)
4. Scan
   - Meal photo (camera/gallery)
   - Packaged (barcode)
5. Scanning/Processing (meal)
6. Food Result (+ dish-category ingredient awareness)
7. Portion Selection
8. Nutrition Result
9. Packaged barcode + Packaged result
10. History
11. Profile/Goals (age, weight, height, gender, activity, goal, logout)

### Website (public / marketing)
1. Home
2. How It Works
3. Features
4. Pricing
5. About
6. Contact
7. Privacy
8. Terms

## 4. Important Product Rules

- Calorie values from an image are **estimates**. UI must not present them as medically exact.
- Dish **ingredient awareness** is category-based typical advice — **not** lab analysis of the plate.
- Packaged checks use product DB + ingredient **rules** — educational only, not medical advice.
- Session: JWT stored on device; splash validates and routes to Home when valid; Profile has explicit Log out.

## 5. Profile & daily calorie target

Profile fields drive `daily_goal_kcal` on save:
- Age, weight (kg), height (cm)
- Gender: Male / Female / Prefer not to say
- Activity: Sedentary / Lightly / Moderately / Very active
- Goal: Lose Weight / Maintain / Gain Muscle

Formula details: `docs/07-calorie-and-estimation-logic.md`.

Home refreshes goal via `GET /api/v1/me/today` when the Home screen loads (e.g. after navigating from Profile).

## 6. Source of truth

These Cursor docs (`01`–`07` + root README / DEPLOY) define product shape and architecture.

Supplementary PDFs or notes may suggest web-first dashboards, different mobile frameworks, or different API shapes. Those suggestions are **non-binding** unless explicitly merged into these docs.

## 7. Future Features

- Packaged OCR / AI deeper label analysis (when barcode missing)
- Indian food recognition improvements (stronger vision model)
- Meal recommendations
- Water tracking
- Health platform integrations
- Subscription/premium features
- Family accounts
- Optional authenticated web client (separate from marketing site)
- Refresh tokens / secure storage hardening
