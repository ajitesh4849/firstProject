from app.adapters.base import FoodRecognitionAdapter
from app.schemas import PredictResponse


class OpenAIVisionAdapter(FoodRecognitionAdapter):
    """
    Placeholder adapter for a future OpenAI Vision integration.

    Not enabled by default. Keep /predict response shape identical when implemented.
    """

    def __init__(self, api_key: str, model: str) -> None:
        self._api_key = api_key
        self._model = model

    async def predict(self, image_bytes: bytes, content_type: str, filename: str | None) -> PredictResponse:
        raise NotImplementedError(
            "OpenAI Vision adapter is not implemented yet. "
            "Set AI_MODEL_PROVIDER=mock or implement this adapter."
        )
