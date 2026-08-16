# FoodScan – Architecture

## Product shape

Mobile-first:

```text
Flutter Mobile (primary product)
        |
        | HTTPS REST
        v
 Spring Boot Backend
        |
        +--> AI Service (FastAPI)          # meal photo recognition
        +--> Open Food Facts (HTTPS)      # packaged barcode lookup (no AI)
        +--> Postgres
```

Marketing site:

```text
Browser → Next.js marketing website
              |
              +--> static/public content (default)
              +--> backend only when required (e.g. contact later)
```

The Next.js site is **not** part of the scan/tracking product loop for MVP.

## Master Structure

```text
foodscan/
├── ui_screens/
│   ├── mobile/       # Flutter Android/iOS application (PRIMARY PRODUCT)
│   └── web_site/     # Next.js public MARKETING website
├── backend/          # Java Spring Boot REST API
├── ai_service/       # Python FastAPI AI service (internal)
├── docs/
├── docker-compose.yml
└── README.md
```

> Keep the first implementation simple. A separate authenticated browser app is **not** required for v1. If needed later, introduce it as another client under `ui_screens/` — do not convert `web_site` into a dashboard.

## Runtime Flow (meal photo)

```text
Flutter App
  → POST /api/v1/scans (image + JWT)
  → Spring Boot → AI /predict
  → Spring Boot returns food name, confidence, ingredient awareness
  → Flutter confirms name → portion → nutrition → add meal
```

## Runtime Flow (packaged food — Phase 1)

```text
Flutter App (barcode camera or manual digits)
  → GET /api/v1/packaged/barcode/{barcode} (JWT)
  → Spring Boot → Open Food Facts product API
  → PackagedFoodRiskAnalyzer (rules: E-numbers, sugar/salt, keywords)
  → Score + flags + healthier swaps
```

No AI call in packaged Phase 1.

## Session / auth

```text
Login/Signup → JWT accessToken
  → stored in SharedPreferences on device
  → loaded in main() via apiClient.loadSession()
  → Splash validates (e.g. GET /api/v1/me/profile)
       → 200 → Home
       → 401 / no token → Login
  → Any API 401 → clear session → Login
  → Profile Log out → clear token → Login
```

JWT expiration is configured in backend (`foodscan.jwt.expiration-ms`, default 24h).

## Responsibilities

### Flutter
- UI / navigation
- camera, gallery, barcode scanning
- client-side validation
- API communication + JWT header
- session persistence (token storage)
- displaying meal + packaged results
- daily tracking / history / profile presentation

Do not put core business rules in widgets (risk scoring and calorie math live in backend).

### Next.js
- public marketing website
- SEO
- responsive pages
- reusable components
- forms that may call backend APIs later (e.g. contact)

Do **not** implement authenticated calorie tracking, scan upload, or meal history here in MVP.

### Spring Boot
- authentication (JWT)
- users / profile + daily calorie goal calculation
- food scan orchestration
- nutrition estimation (name + portion)
- dish-category ingredient awareness on scan response
- packaged barcode analysis (Open Food Facts + rules)
- persistence (Postgres)
- API contracts
- authorization / validation / rate limits

### AI Service
- image preprocessing
- food recognition for **meal photos**
- confidence score
- return structured prediction
- model/provider adapter abstraction (`mock` or OpenAI vision)

AI service must not own user authentication, packaged barcode rules, or user history.

### Open Food Facts
- External public product database
- Used only by backend for packaged barcode lookup

## API Boundary

Flutter / Next.js never call the AI service or Open Food Facts directly.

Correct:

```text
Client → Spring Boot → AI Service
Client → Spring Boot → Open Food Facts
```

Incorrect:

```text
Client → AI Service
Client → Open Food Facts
```

For MVP, the primary API consumer is **Flutter**. The marketing site should not depend on scan/meal/packaged APIs.

## Docker Compose services

| Service | Role |
|---------|------|
| `postgres` | Persistence (`foodscan_pgdata` volume). Rarely needs rebuild on app feature changes. |
| `backend` | Spring Boot API — rebuild when Java/API changes |
| `ai_service` | Food recognition |
| `website` | Marketing site |

Hibernate `ddl-auto=update` applies new columns (e.g. `gender`, `activity_level`) when backend starts against a running Postgres — Postgres container itself usually does not restart.
