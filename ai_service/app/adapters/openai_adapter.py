import base64
import json
import re
from typing import Any

import httpx

from app.adapters.base import FoodRecognitionAdapter
from app.schemas import PredictResponse

OPENAI_CHAT_URL = "https://api.openai.com/v1/chat/completions"

SYSTEM_PROMPT = (
    "You are a food recognition assistant for a calorie-tracking app. "
    "Look at the meal photo and identify the primary dish. "
    "Respond with JSON only in this exact shape: "
    '{"foodName":"<common dish name>","confidence":<number from 0 to 1>}. '
    "Prefer everyday dish names (for example: Paneer Butter Masala, Masala Dosa, Margherita Pizza). "
    "If the image is not food, set foodName to \"Unknown food\" and confidence below 0.4."
)


class OpenAIVisionAdapter(FoodRecognitionAdapter):
    """Calls OpenAI Chat Completions with vision to identify food in an image."""

    def __init__(self, api_key: str, model: str, timeout_seconds: float = 60.0) -> None:
        self._api_key = api_key
        self._model = model
        self._timeout_seconds = timeout_seconds

    async def predict(self, image_bytes: bytes, content_type: str, filename: str | None) -> PredictResponse:
        encoded = base64.b64encode(image_bytes).decode("ascii")
        data_url = f"data:{content_type};base64,{encoded}"

        payload: dict[str, Any] = {
            "model": self._model,
            "temperature": 0.2,
            "max_tokens": 120,
            "response_format": {"type": "json_object"},
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Identify the primary food in this image.",
                        },
                        {
                            "type": "image_url",
                            "image_url": {"url": data_url},
                        },
                    ],
                },
            ],
        }

        headers = {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
        }

        async with httpx.AsyncClient(timeout=self._timeout_seconds) as client:
            response = await client.post(OPENAI_CHAT_URL, headers=headers, json=payload)

        if response.status_code >= 400:
            detail = response.text[:500]
            raise RuntimeError(f"OpenAI API error {response.status_code}: {detail}")

        body = response.json()
        try:
            content = body["choices"][0]["message"]["content"]
        except (KeyError, IndexError, TypeError) as exc:
            raise RuntimeError(f"Unexpected OpenAI response shape: {body}") from exc

        parsed = _parse_prediction(content)
        food_name = str(parsed.get("foodName") or parsed.get("food_name") or "").strip()
        if not food_name:
            raise RuntimeError(f"OpenAI response missing foodName: {content}")

        confidence = _to_confidence(parsed.get("confidence", 0.7))
        return PredictResponse(foodName=food_name, confidence=confidence)


def _parse_prediction(content: str) -> dict[str, Any]:
    text = (content or "").strip()
    if not text:
        raise RuntimeError("OpenAI returned empty content")

    try:
        data = json.loads(text)
        if isinstance(data, dict):
            return data
    except json.JSONDecodeError:
        pass

    match = re.search(r"\{.*\}", text, flags=re.DOTALL)
    if match:
        data = json.loads(match.group(0))
        if isinstance(data, dict):
            return data

    raise RuntimeError(f"Could not parse OpenAI JSON content: {text}")


def _to_confidence(value: Any) -> float:
    try:
        confidence = float(value)
    except (TypeError, ValueError):
        confidence = 0.7
    return max(0.0, min(1.0, round(confidence, 2)))
