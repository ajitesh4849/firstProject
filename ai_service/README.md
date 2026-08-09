# FoodScan AI Service (FastAPI)

Internal food recognition service. **Only Spring Boot should call this.**

## Requirements

- Python 3.12+
- pip

## Setup

```powershell
cd ai_service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

## Run

```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

- Health: http://localhost:8000/health
- Predict: `POST /predict` multipart field `image`

## Test

```powershell
pytest -q
```

## Config

| Variable | Default | Notes |
|---|---|---|
| `AI_MODEL_PROVIDER` | `mock` | `mock` or `openai` |
| `OPENAI_API_KEY` | unset | Required when provider is `openai` |
| `OPENAI_VISION_MODEL` | `gpt-4o-mini` | Vision-capable chat model |
| `AI_SERVICE_PORT` | `8000` | Used by docs/ops; uvicorn port flag wins locally |

## Enable real image analysis (OpenAI Vision)

1. Put your key in repo-root `.env` (or `ai_service/.env` for local uvicorn):

```env
AI_MODEL_PROVIDER=openai
OPENAI_API_KEY=sk-...
OPENAI_VISION_MODEL=gpt-4o-mini
```

2. Restart AI:

```powershell
docker compose up -d --build ai_service
```

Health should show `"provider":"openai"`.

## Adapter design

```text
/predict → FoodRecognitionAdapter → MockFoodRecognitionAdapter (default)
                                  → OpenAIVisionAdapter
```

Response contract stays:

```json
{ "foodName": "Paneer Butter Masala", "confidence": 0.92 }
```
