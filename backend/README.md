AI is called by Spring Boot during `POST /api/v1/scans`.

## Run

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Health: http://localhost:8080/api/v1/health

Ensure AI service is running on `AI_SERVICE_BASE_URL` (default `http://localhost:8000`).

## Test

```powershell
.\mvnw.cmd test
```

## Configuration (env)

| Variable | Default | Purpose |
|---|---|---|
| `SERVER_PORT` | `8080` | HTTP port |
| `AI_SERVICE_BASE_URL` | `http://localhost:8000` | FastAPI AI |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:3000` | Allowed browser origins |

## Implemented contracts

- `GET /api/v1/health`
- `POST /api/v1/auth/login`
- `POST /api/v1/scans` (multipart `image`) → calls AI `/predict`
- `POST /api/v1/scans/{scanId}/nutrition`
- `POST /api/v1/meals`
- `GET /api/v1/me/today`
- `GET /api/v1/me/history`
- `GET /api/v1/me/profile`
- `PUT /api/v1/me/profile`

Persistence and JWT hardening come later.

## Package layout

```text
com.foodscan.backend
├── client       # AiServiceClient
├── controller
├── service
├── dto
├── exception
└── config
```
