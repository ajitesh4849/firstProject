import base64
import json
import re
from typing import Any

import httpx

from app.adapters.base import FoodRecognitionAdapter
from app.schemas import LabelReadResponse, PredictResponse

OPENAI_CHAT_URL = "https://api.openai.com/v1/chat/completions"

SYSTEM_PROMPT = (
    "You are a food recognition assistant for a calorie-tracking app. "
    "Look at the meal photo and identify the primary dish. "
    "Respond with JSON only in this exact shape: "
    '{"foodName":"<common dish name>","confidence":<number from 0 to 1>}. '
    "Prefer everyday dish names (for example: Paneer Butter Masala, Masala Dosa, Margherita Pizza). "
    "If the image is not food, set foodName to \"Unknown food\" and confidence below 0.4."
)

LABEL_SYSTEM_PROMPT = (
    "You read packaged-food ingredient labels for a consumer health app. "
    "Extract the product name (if visible), brand (if visible), and the full ingredients list text. "
    "Respond with JSON only in this exact shape: "
    '{"productName":"<name or Unknown product>","brand":"<brand or null>",'
    '"ingredientsText":"<ingredients as plain text>","confidence":<number from 0 to 1>}. '
    "Preserve ingredient names and E-numbers. If the image is not a food label, "
    "set ingredientsText to an empty string and confidence below 0.4."
)


class OpenAIVisionAdapter(FoodRecognitionAdapter):
    """Calls OpenAI Chat Completions with vision to identify food in an image."""

    def __init__(self, api_key: str, model: str, timeout_seconds: float = 60.0) -> None:
        self._api_key = api_key
        self._model = model
        self._timeout_seconds = timeout_seconds

    async def predict(self, image_bytes: bytes, content_type: str, filename: str | None) -> PredictResponse:
        parsed = await self._vision_json(
            system_prompt=SYSTEM_PROMPT,
            user_text="Identify the primary food in this image.",
            image_bytes=image_bytes,
            content_type=content_type,
            max_tokens=120,
        )
        food_name = str(parsed.get("foodName") or parsed.get("food_name") or "").strip()
        if not food_name:
            raise RuntimeError(f"OpenAI response missing foodName: {parsed}")

        confidence = _to_confidence(parsed.get("confidence", 0.7))
        return PredictResponse(foodName=food_name, confidence=confidence)

    async def read_label(
        self, image_bytes: bytes, content_type: str, filename: str | None
    ) -> LabelReadResponse:
        parsed = await self._vision_json(
            system_prompt=LABEL_SYSTEM_PROMPT,
            user_text="Read the packaged food ingredients label in this photo.",
            image_bytes=image_bytes,
            content_type=content_type,
            max_tokens=500,
        )
        ingredients = str(
            parsed.get("ingredientsText") or parsed.get("ingredients_text") or ""
        ).strip()
        if not ingredients:
            raise RuntimeError("Could not read ingredients from this photo")

        product_name = str(
            parsed.get("productName") or parsed.get("product_name") or "Unknown product"
        ).strip() or "Unknown product"
        brand_raw = parsed.get("brand")
        brand = None if brand_raw in (None, "", "null") else str(brand_raw).strip()
        confidence = _to_confidence(parsed.get("confidence", 0.75))
        return LabelReadResponse(
            productName=product_name,
            brand=brand,
            ingredientsText=ingredients,
            confidence=confidence,
        )

    async def _vision_json(
        self,
        *,
        system_prompt: str,
        user_text: str,
        image_bytes: bytes,
        content_type: str,
        max_tokens: int,
    ) -> dict[str, Any]:
        encoded = base64.b64encode(image_bytes).decode("ascii")
        data_url = f"data:{content_type};base64,{encoded}"

        payload: dict[str, Any] = {
            "model": self._model,
            "temperature": 0.2,
            "max_tokens": max_tokens,
            "response_format": {"type": "json_object"},
            "messages": [
                {"role": "system", "content": system_prompt},
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": user_text},
                        {"type": "image_url", "image_url": {"url": data_url}},
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

        return _parse_prediction(content)


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
