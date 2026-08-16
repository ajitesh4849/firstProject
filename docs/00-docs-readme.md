# FoodScan – Cursor Build Documentation

These documents are the **source of truth** for FoodScan architecture, UX, and implementation.

## Product decision (locked)

**Mobile-first FoodScan.**

| Surface | Role |
|---|---|
| **Flutter (Android/iOS)** | Primary product — scan, nutrition, tracking, history, profile |
| **Next.js website** | Marketing / SEO / public info only — not a calorie-tracking app |
| **Spring Boot** | Auth, orchestration, persistence, nutrition aggregation |
| **FastAPI AI** | Internal food recognition only (clients never call it directly) |

Do **not** build an authenticated web dashboard in the Next.js site for MVP.

Older / alternate PDFs that describe a “web MVP dashboard first” or React Native are **not** authoritative. Use them only as optional reference for security checklists, DB sketches, or AI provider ideas — never to change product shape without an explicit decision update here.

## Recommended order for Cursor

1. `01-product-requirements.md`
2. `02-architecture.md`
3. `03-mobile-flutter-spec.md`
4. `04-website-nextjs-spec.md`
5. `05-api-contracts.md`
6. `06-cursor-build-instructions.md`
7. `07-calorie-and-estimation-logic.md` — daily goal math, meal estimates, ingredient awareness (explainers)

## Important

- Build UI first (Flutter, then marketing website).
- Do not invent screens or change the agreed architecture without asking.
- Mobile app: Flutter/Dart.
- Public website: React + Next.js + TypeScript (**marketing only**).
- Backend: Java + Spring Boot.
- AI service: Python + FastAPI (adapter pattern; model/provider can change later).
- Flutter communicates with the backend through REST APIs.
- Website may call backend only where required (e.g. contact form later).
- Backend communicates with the AI service.
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
