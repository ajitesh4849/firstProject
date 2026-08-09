from app.adapters.base import FoodRecognitionAdapter
from app.schemas import PredictResponse


class MockFoodRecognitionAdapter(FoodRecognitionAdapter):
    """Deterministic stub until a real model/provider is selected."""

    async def predict(self, image_bytes: bytes, content_type: str, filename: str | None) -> PredictResponse:
        name = "Paneer Butter Masala"
        lowered = (filename or "").lower()
        if "dosa" in lowered:
            name = "Masala Dosa"
        elif "salad" in lowered:
            name = "Garden Salad"
        elif "pizza" in lowered:
            name = "Margherita Pizza"

        # Slightly vary confidence from file size so responses look realistic.
        confidence = 0.92
        if image_bytes:
            confidence = min(0.98, 0.85 + (len(image_bytes) % 100) / 1000)

        return PredictResponse(foodName=name, confidence=round(confidence, 2))
