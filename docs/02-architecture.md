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
        | HTTP/REST (internal)
        v
   AI Service (FastAPI)
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
└── README.md
```

> Keep the first implementation simple. A separate authenticated browser app is **not** required for v1. If needed later, introduce it as another client under `ui_screens/` — do not convert `web_site` into a dashboard.

## Runtime Flow (product)

```text
Android/iOS Flutter App
          |
          | HTTPS REST API
          v
   Spring Boot Backend
          |
          | HTTP/REST
          v
     AI Service
     Python/FastAPI
          |
          v
 Food recognition model / provider adapter

Backend also communicates with:
- nutrition data provider
- database
- authentication / storage services
```

## Website Flow (marketing)

```text
Browser
  |
  v
Next.js Website
  |
  +--> public marketing content
  |
  +--> backend APIs only where required (not for scan/tracking in MVP)
```

## Responsibilities

### Flutter
- UI
- navigation
- camera/image selection
- client-side validation
- API communication
- displaying results
- daily tracking / history / profile presentation

Do not put core business rules in widgets.

### Next.js
- public marketing website
- SEO
- responsive pages
- reusable components
- forms that may call backend APIs later (e.g. contact)

Do **not** implement authenticated calorie tracking, scan upload, or meal history here in MVP.

### Spring Boot
- authentication
- users
- food scan orchestration
- nutrition calculations/aggregation
- persistence
- API contracts
- calling AI service
- authorization
- validation

### AI Service
- image preprocessing
- food recognition
- confidence score
- return structured prediction
- model/provider adapter abstraction (implementation may use a cloud vision API initially)

AI service must not own user authentication or user history.

## API Boundary

Flutter / Next.js never call the AI service directly.

Correct:

```text
Client → Spring Boot → AI Service
```

Incorrect:

```text
Client → AI Service
```

For MVP, the primary API consumer is **Flutter**. The marketing site should not depend on scan/meal APIs.
