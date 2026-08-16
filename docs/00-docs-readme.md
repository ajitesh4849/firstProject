# FoodScan – Cursor Build Documentation

These documents are the **source of truth** for FoodScan architecture, UX, and implementation.

## Product decision (locked)

**Mobile-first FoodScan.**

| Surface | Role |
|---|---|
| **Flutter (Android/iOS)** | Primary product — meal + packaged scan, nutrition, tracking, history, profile, session |
| **Next.js website** | Marketing / SEO / public info only — not a calorie-tracking app |
| **Spring Boot** | Auth/JWT, orchestration, persistence, nutrition, awareness rules, packaged OFF+rules |
| **FastAPI AI** | Internal **meal photo** recognition only (clients never call it; packaged Phase 1 skips AI) |

Do **not** build an authenticated web dashboard in the Next.js site for MVP.

Older / alternate PDFs that describe a “web MVP dashboard first” or React Native are **not** authoritative. Use them only as optional reference for security checklists, DB sketches, or AI provider ideas — never to change product shape without an explicit decision update here.

## Recommended order for Cursor

1. `01-product-requirements.md`
2. `02-architecture.md`
3. `03-mobile-flutter-spec.md`
4. `04-website-nextjs-spec.md`
5. `05-api-contracts.md`
6. `06-cursor-build-instructions.md`
7. `07-calorie-and-estimation-logic.md` — daily goal math, meal estimates, ingredient awareness, packaged barcode rules

## Current product surfaces (docs must stay aligned)

| Area | Doc |
|------|-----|
| Meal vs packaged scan UX | `03`, `01` |
| Session gate + logout | `02`, `03` |
| Profile gender/activity → daily goal | `05`, `07` |
| Scan `awareness` + packaged API | `05`, `07` §9 |
| OFF + risk engine (no AI) | `02`, `07` |

## Important

- Do not invent screens or change the agreed architecture without asking.
- Mobile app: Flutter/Dart (JWT session, meal camera, barcode).
- Public website: React + Next.js + TypeScript (**marketing only**).
- Backend: Java + Spring Boot (auth, nutrition, awareness, packaged).
- AI service: Python + FastAPI for meal photos only (adapter pattern).
- Flutter → Spring Boot only; never call AI or Open Food Facts directly.
- Keep UI, backend, and AI as independently runnable projects.

## Implementation repo layout

```text
foodscan/   (or project root)
├── ui_screens/
│   ├── mobile/       # Flutter — primary product
│   └── web_site/     # Next.js — marketing site
├── backend/
├── ai_service/
├── docs/             # Copy or symlink of these docs
└── README.md
```
