# FoodScan

AI-powered food scanning and calorie tracking.

## Product decision (locked)

**Mobile-first.** Flutter is the primary product. Next.js is a **marketing website only** (no web tracker in MVP).

Source of truth: `docs/` (synced from `foodscan_cursor_docs`).

## Architecture

```text
Flutter Mobile → Spring Boot Backend → AI Service
Next.js Website → Spring Boot Backend (only when backend functionality is required)
```

```text
foodscan/
├── ui_screens/
│   ├── mobile/       # Flutter Android/iOS (Phase 1 – UI ✓)
│   └── web_site/     # Next.js marketing site (Phase 2)
├── backend/          # Spring Boot REST API (Phase 4)
├── ai_service/       # Python FastAPI (Phase 5)
├── docs/
└── README.md
```

## Current status

**Phase 1 – Mobile UI** ✓ — Flutter app with mock data  
**Phase 2 – Marketing website** ✓ — Next.js public site  
**Phase 3 – UX polish** ✓ — loading / empty / error / success states  
**Phase 4 – Backend (started)** ✓ — Spring Boot + **Maven**, in-memory API stubs

## Run the Flutter app

```bash
cd ui_screens/mobile
flutter pub get
flutter run
```

### Demo flow

Splash → Login → Home → Scan → Scanning → Food Result → Portion → Nutrition → Home  
Bottom nav: Home ↔ History ↔ Profile

UX tips:
- Login password `fail` → error state
- Long-press **Scan Food** → simulated detection failure + retry

## Run the marketing website

```bash
cd ui_screens/web_site
npm install
npm run dev
```

Open http://localhost:3000

Contact tip: email `fail@example.com` → submit error state

## Run the backend (Maven)

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Health: http://localhost:8080/api/v1/health

```powershell
.\mvnw.cmd test
```

## Docs

See `docs/` for product requirements, architecture, Flutter spec, website spec, API contracts, and Cursor build instructions.

## Next phases

5. FastAPI AI service (wire backend scan → `/predict`)  
Also: real JWT, PostgreSQL persistence  
