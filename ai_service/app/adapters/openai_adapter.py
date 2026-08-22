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
    "You read packaged-food labels for a consumer health app. "
    "Extract: (1) brand name from the logo or front/back packaging if visible, "
    "(2) product name, (3) the full ingredients list text. "
    "Brand is important — look near the top of the pack, logo, or manufacturer line. "
    "Respond with JSON only in this exact shape: "
    '{"productName":"<name or Unknown product>","brand":"<brand or null>",'
    '"ingredientsText":"<ingredients as plain text>","confidence":<number from 0 to 1>}. '
    "If brand is not clearly visible, set brand to null (do not invent a brand). "
    "Preserve ingredient names and E-numbers. If the image is not a food label, "
    "set ingredientsText to an empty string and confidence below 0.4."
)


class OpenAIVisionAdapter(FoodRecognitionAdapter):
    """Calls OpenAI Chat Completions with vision to identify food in an image."""

    def __init__(self, api_key: str, model: str, timeout_seconds: float = 35.0) -> None:
        self._api_key = api_key
        self._model = model
        self._timeout_seconds = timeout_seconds

    async def predict(self, image_bytes: bytes, content_type: str, filename: str | None) -> PredictResponse:
        parsed = await self._vision_json(
            system_prompt=SYSTEM_PROMPT,
            user_text="Identify the primary food in this image.",
            image_bytes=image_bytes,
            content_type=content_type,
            max_tokens=80,
            image_detail="low",
            timeout_seconds=min(self._timeout_seconds, 25.0),
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
            user_text="Read this packaged food label. Prefer extracting brand and product name if visible, then the ingredients list.",
            image_bytes=image_bytes,
            content_type=content_type,
            max_tokens=350,
            image_detail="high",
            timeout_seconds=self._timeout_seconds,
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
        image_detail: str = "auto",
        timeout_seconds: float | None = None,
    ) -> dict[str, Any]:
        # Large base64 payloads are a common latency source; refuse oversized originals early.
        payload_bytes = _ensure_reasonable_image_size(image_bytes)
        encoded = base64.b64encode(payload_bytes).decode("ascii")
        data_url = f"data:{content_type};base64,{encoded}"

        payload: dict[str, Any] = {
            "model": self._model,
            "temperature": 0.1,
            "max_tokens": max_tokens,
            "response_format": {"type": "json_object"},
            "messages": [
                {"role": "system", "content": system_prompt},
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": user_text},
                        {
                            "type": "image_url",
                            "image_url": {"url": data_url, "detail": image_detail},
                        },
                    ],
                },
            ],
        }

        headers = {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
        }

        timeout = timeout_seconds if timeout_seconds is not None else self._timeout_seconds
        async with httpx.AsyncClient(timeout=timeout) as client:
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


def _ensure_reasonable_image_size(image_bytes: bytes) -> bytes:
    """Fail fast on huge gallery originals (client should already compress)."""
    if len(image_bytes) > 3 * 1024 * 1024:
        raise RuntimeError("Image too large for fast analysis. Use a closer, compressed photo.")
    return image_bytes


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
