# Deploy FoodScan with Docker Compose

## 1. Create `.env`

```powershell
copy .env.example .env
```

Generate a JWT secret:

```powershell
$bytes = New-Object byte[] 48
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

Paste the result into `.env` as `JWT_SECRET=...`.

Keep `AI_MODEL_PROVIDER=mock` until you add an OpenAI key.

## 2. Start the stack

```powershell
docker compose up --build -d
```

## 3. Verify

- Website: http://localhost:3000  
- API: http://localhost:8080/api/v1/health  
- AI: http://localhost:8000/health  

## 4. Stop

```powershell
docker compose down
```

Data in Postgres persists in the `foodscan_pgdata` volume.
