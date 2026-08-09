import asyncio
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from app.adapters.openai_adapter import OpenAIVisionAdapter
from app.config import get_settings
from app.main import app
from app.schemas import PredictResponse


@pytest.fixture(autouse=True)
def clear_settings_cache() -> None:
    get_settings.cache_clear()
    yield
    get_settings.cache_clear()


def test_openai_adapter_parses_json_response() -> None:
    adapter = OpenAIVisionAdapter(api_key="test-key", model="gpt-4o-mini")

    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "choices": [
            {
                "message": {
                    "content": '{"foodName":"Masala Dosa","confidence":0.91}',
                }
            }
        ]
    }

    mock_client = AsyncMock()
    mock_client.post.return_value = mock_response
    mock_client.__aenter__.return_value = mock_client
    mock_client.__aexit__.return_value = None

    with patch("app.adapters.openai_adapter.httpx.AsyncClient", return_value=mock_client):
        result = asyncio.run(adapter.predict(b"fake-bytes", "image/jpeg", "dosa.jpg"))

    assert result == PredictResponse(foodName="Masala Dosa", confidence=0.91)
    mock_client.post.assert_awaited_once()


def test_openai_adapter_raises_on_api_error() -> None:
    adapter = OpenAIVisionAdapter(api_key="test-key", model="gpt-4o-mini")

    mock_response = MagicMock()
    mock_response.status_code = 401
    mock_response.text = "invalid api key"

    mock_client = AsyncMock()
    mock_client.post.return_value = mock_response
    mock_client.__aenter__.return_value = mock_client
    mock_client.__aexit__.return_value = None

    with patch("app.adapters.openai_adapter.httpx.AsyncClient", return_value=mock_client):
        with pytest.raises(RuntimeError, match="OpenAI API error 401"):
            asyncio.run(adapter.predict(b"fake-bytes", "image/jpeg", "meal.jpg"))


def test_factory_requires_openai_key(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("AI_MODEL_PROVIDER", "openai")
    monkeypatch.delenv("OPENAI_API_KEY", raising=False)
    get_settings.cache_clear()

    client = TestClient(app)
    files = {"image": ("meal.jpg", b"fake-image-bytes", "image/jpeg")}
    response = client.post("/predict", files=files)
    assert response.status_code == 500
    assert "OPENAI_API_KEY" in response.json()["detail"]
