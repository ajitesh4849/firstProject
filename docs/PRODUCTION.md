# Production launch checklist

## 1. Secrets & JWT

In `.env` (never commit):

```env
JWT_SECRET=<unique random string, 32+ characters>
JWT_ALLOW_WEAK_SECRET=false
POSTGRES_PASSWORD=<strong password>
FOOD_IDENTIFIER=catalog
```

The backend **refuses to start** with the default JWT secret when `JWT_ALLOW_WEAK_SECRET=false` (the default in `application.yml`).

## 2. HTTPS

Terminate TLS at your reverse proxy / cloud load balancer (Caddy, nginx, Traefik, Cloud Run, ALB, etc.) and forward to the backend on port 8080.

Point:

- `API_BASE_URL` → `https://api.yourdomain.com`
- Website → `https://yourdomain.com` (privacy `/privacy`, terms `/terms`)

Set CORS:

```env
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

## 3. Database backups

Postgres data lives in the Compose volume `foodscan_pgdata`.

**Minimum:**

```powershell
# Logical dump (schedule daily via cron / Task Scheduler / cloud job)
docker compose exec -T postgres pg_dump -U foodscan foodscan > backup-$(Get-Date -Format yyyyMMdd).sql
```

Prefer managed Postgres (RDS, Cloud SQL, Neon, Supabase) with automated backups for production.

## 4. Flutter production build

```powershell
cd ui_screens/mobile
flutter pub get
flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com --dart-define=LEGAL_BASE_URL=https://yourdomain.com
# or
flutter build ios --dart-define=API_BASE_URL=https://api.yourdomain.com --dart-define=LEGAL_BASE_URL=https://yourdomain.com
```

Do **not** ship the emulator default (`10.0.2.2` / localhost).

## 5. Store listing copy (meal scan)

Be explicit:

> Meal photos: you name the dish from our food catalog. Calories come from our database for the portion you pick. Automatic AI dish recognition is not included in this version.

## 6. Account deletion

Users can delete their account in **Profile → Delete account** (`DELETE /api/v1/me/account`), which removes profile, meals, scans, and user-contributed packaged seeds.

## 7. Smoke test before store submit

1. Signup / login over HTTPS  
2. Meal photo → type dish → portion → Add to Today  
3. Packaged barcode  
4. Search / compare  
5. Profile save  
6. Delete account  
7. Open Privacy + Terms from login/profile  
