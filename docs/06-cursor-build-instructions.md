# FoodScan – Cursor Master Build Instructions

## Role

Act as a senior full-stack engineer building the FoodScan project from the supplied documentation.

Read ALL files under `docs/` (and the package README) before changing code.

## Source of truth

These Cursor docs define the product. Supplementary PDFs that describe a web dashboard MVP, React Native, or different API layouts are **not** binding unless merged here.

**Locked product decision:** Mobile-first. Flutter is the product. Next.js is marketing only.

## Non-negotiable architecture

```text
Flutter Mobile → Spring Boot Backend → AI Service
Next.js Website → Spring Boot Backend (only when backend functionality is required)
```

Do not make Flutter or Next.js call the AI service directly.

Do not turn the Next.js marketing site into an authenticated tracker in MVP.

## Development order

### Phase 1 – Mobile UI
Build the Flutter UI from `03-mobile-flutter-spec.md`.

Requirements:
- Keep current Flutter project runnable.
- Use Dart null safety.
- Use Material 3.
- Create the agreed folder structure.
- Implement all mobile screens.
- Implement navigation.
- Use mock/static data.
- No backend calls.
- No AI calls.
- No authentication implementation yet.
- Camera can be a placeholder in the first UI phase.

### Phase 2 – Marketing website
Build the Next.js website from `04-website-nextjs-spec.md`.

Requirements:
- App Router
- TypeScript
- Responsive
- SEO metadata
- Reusable components
- No unnecessary dependencies
- Mock contact submission
- No payment integration
- **Marketing pages only** — no login, dashboard, upload, history, or profile tracking UI

### Phase 3 – UX refinement
After both clients run:
- identify missing loading, empty, error and success states
- improve navigation
- do not silently remove agreed functionality
- propose changes before making major UX changes

### Phase 4 – Backend
Build Spring Boot APIs from `05-api-contracts.md`.

Requirements:
- Java 21
- Spring Boot
- **Maven** for dependency management (`pom.xml` + Maven Wrapper `mvnw`)
- REST
- validation
- clean controller/service/repository separation
- centralized exception handling
- DTOs instead of exposing persistence entities
- configuration via environment variables
- tests for services/controllers
- OpenAPI documentation later
- Primary consumer of these APIs is Flutter

### Phase 5 – AI
Build Python FastAPI service.

Initial implementation:
- `/health`
- `/predict`
- structured response
- model adapter abstraction so the actual model can be replaced later
- do not hard-code a production ML model until one is selected
- validate image input
- return confidence score
- return useful errors

A cloud vision API (e.g. OpenAI Vision) may be used behind the adapter for early MVP; keep the `/predict` contract stable.

## Coding rules

1. Do not rewrite working code unnecessarily.
2. Do not introduce libraries unless needed.
3. Do not invent APIs or database schemas that conflict with the docs.
4. Keep modules independently runnable.
5. Keep secrets out of source control.
6. Use `.env`/environment configuration where appropriate.
7. Add README/setup instructions to each service.
8. Prefer small, reviewable changes.
9. After each phase, explain files changed and how to run them.
10. If a requirement is ambiguous, ask before making a major architectural decision.
11. If another document conflicts with these Cursor docs, follow these docs and ask before changing product shape.

## UI fidelity

The low-fidelity wireframes / mobile + website specs are the UX source of truth. Preserve:
- screen order
- primary actions
- navigation
- information hierarchy

Visual styling can be improved professionally while keeping the agreed UX.

## Definition of done

Mobile:
- Flutter app runs on Android emulator.
- All agreed screens are navigable.
- No backend/AI dependency required for UI demo.

Website:
- Next.js app runs locally.
- All public marketing pages work.
- Responsive layout works.
- No authenticated tracking features included.

Backend:
- Spring Boot starts successfully.
- Health endpoint works.
- API contracts are implemented incrementally.

AI:
- FastAPI starts successfully.
- Health endpoint works.
- Predict endpoint returns the documented structure.

## Current Cursor task guidance

Do NOT build the entire system in one step.

Follow phases in order. After Phase 1 is complete, implement Phase 2 (marketing website only).

Before editing in any phase:
1. inspect the current project
2. read the docs
3. list the files you plan to create/change
4. then implement that phase only
