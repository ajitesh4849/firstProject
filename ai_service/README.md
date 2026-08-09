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
| `AI_MODEL_PROVIDER` | `mock` | `mock` now; `openai` reserved |
| `OPENAI_API_KEY` | unset | Required only for openai provider later |
| `AI_SERVICE_PORT` | `8000` | Used by docs/ops; uvicorn port flag wins locally |

## Adapter design

```text
/predict → FoodRecognitionAdapter → MockFoodRecognitionAdapter (default)
                                  → OpenAIVisionAdapter (placeholder)
```

Swap providers without changing the response contract:

```json
{ "foodName": "Paneer Butter Masala", "confidence": 0.92 }
```
