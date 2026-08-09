# FoodScan

AI-powered food scanning and calorie tracking.

## Product decision (locked)

**Mobile-first.** Flutter is the primary product. Next.js is a **marketing website only** (no web tracker in MVP).

Source of truth: `docs/` (synced from `foodscan_cursor_docs`).

## Architecture

```text
Flutter Mobile → Spring Boot Backend → AI Service + PostgreSQL
Next.js Website (Docker service, marketing only)
```

```text
foodscan/
├── ui_screens/
│   ├── mobile/       # Flutter Android/iOS
│   └── web_site/     # Next.js marketing site (Compose: website)
├── backend/          # Spring Boot + Maven + PostgreSQL + JWT
├── ai_service/       # Python FastAPI
├── docker-compose.yml
├── docs/
└── README.md
```

## Current status

| Area | Status |
|---|---|
| Flutter UI + camera/gallery scan | Done |
| Marketing site | Done |
| Spring Boot REST + JWT signup/login | Done |
| PostgreSQL persistence (users, meals, scans) | Done |
| FastAPI AI (mock adapter) | Done |
| Docker Compose (Postgres + AI + backend + website) | Done |

## Quick start with Docker

```powershell
docker compose up --build
```

- Marketing site: http://localhost:3000  
- API health: http://localhost:8080/api/v1/health  
- AI health: http://localhost:8000/health  
- Postgres: `localhost:5432` (`foodscan` / `foodscan` / `foodscan`)

Then run Flutter:

```powershell
cd ui_screens/mobile
flutter pub get
flutter run -d emulator-5554
```

Create an account from the login screen (signup), then scan with Camera or Gallery.

Android emulator API base URL is `http://10.0.2.2:8080`.

## Local run without Docker

1. Start Postgres (or use Compose only for Postgres: `docker compose up postgres -d`).
2. AI service:

```powershell
cd ai_service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

3. Backend:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Defaults expect Postgres at `jdbc:postgresql://localhost:5432/foodscan` with user/password `foodscan`.

## Website (optional)

```powershell
cd ui_screens/web_site
npm install
npm run dev
```

## Docs

See `docs/` for product requirements, architecture, Flutter spec, website spec, API contracts, and Cursor build instructions.

## Still remaining

1. Add OpenAI key later (`AI_MODEL_PROVIDER=openai`) for real photo analysis
2. iPhone device QA on MacBook
3. Cloud hosting beyond local Docker
4. Optional: richer nutrition database

See `docs/DEPLOY.md` for running the hardened Compose stack.
