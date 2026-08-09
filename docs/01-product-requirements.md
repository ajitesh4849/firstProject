# FoodScan – Product Requirements

## 1. Product

FoodScan is a food-scanning and calorie-tracking application.

**Primary product:** Flutter mobile app (Android + iOS).

**Public website:** Marketing and SEO only. It explains the product; it does not replace the mobile tracker in MVP.

Core user journey (mobile):

Scan food → identify food → confirm food → select portion → estimate calories/nutrition → add to daily intake → track history.

## 2. Platforms

### Mobile (primary)
Flutter/Dart application targeting:
- Android
- iOS

Owns the full authenticated user journey: login, scan, portion, nutrition, today/history, profile/goals.

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

### AI
Python + FastAPI service for food image recognition/inference.

Clients never call the AI service directly.

## 3. Initial MVP

### Mobile
1. Splash
2. Login
3. Home/Today
4. Scan
5. Scanning/Processing
6. Food Result
7. Portion Selection
8. Nutrition Result
9. History
10. Profile/Goals

### Website (public / marketing)
1. Home
2. How It Works
3. Features
4. Pricing
5. About
6. Contact
7. Privacy
8. Terms

## 4. Important Product Rule

Calorie values from an image are estimates. The UI must communicate that nutrition and portion estimates are approximate and should not be presented as medically exact.

## 5. Source of truth

These Cursor docs (`01`–`06` + root README) define product shape and architecture.

Supplementary PDFs or notes may suggest web-first dashboards, different mobile frameworks, or different API shapes. Those suggestions are **non-binding** unless explicitly merged into these docs.

## 6. Future Features

- Barcode scanning
- Indian food recognition improvements
- Meal recommendations
- Water tracking
- Health platform integrations
- Subscription/premium features
- Family accounts
- Optional authenticated web client (separate from marketing site)
