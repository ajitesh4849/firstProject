from app.adapters.base import FoodRecognitionAdapter
from app.schemas import LabelReadResponse, PredictResponse


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

    async def read_label(
        self, image_bytes: bytes, content_type: str, filename: str | None
    ) -> LabelReadResponse:
        confidence = 0.88
        if image_bytes:
            confidence = min(0.95, 0.8 + (len(image_bytes) % 100) / 1000)

        return LabelReadResponse(
            productName="Sample biscuit pack",
            brand="Demo Brand",
            ingredientsText=(
                "Refined wheat flour (maida), sugar, refined palm oil, "
                "invert syrup, raising agents (503(ii), 500(ii)), salt, "
                "emulsifier (soy lecithin), artificial flavouring substances"
            ),
            confidence=round(confidence, 2),
        )
