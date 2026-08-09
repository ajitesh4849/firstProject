from app.adapters.base import FoodRecognitionAdapter
from app.adapters.mock_adapter import MockFoodRecognitionAdapter
from app.adapters.openai_adapter import OpenAIVisionAdapter
from app.config import Settings


def build_adapter(settings: Settings) -> FoodRecognitionAdapter:
    provider = settings.ai_model_provider.strip().lower()
    if provider == "mock":
        return MockFoodRecognitionAdapter()
    if provider == "openai":
        if not settings.openai_api_key:
            raise ValueError("OPENAI_API_KEY is required when AI_MODEL_PROVIDER=openai")
        return OpenAIVisionAdapter(settings.openai_api_key, settings.openai_vision_model)
    raise ValueError(f"Unsupported AI_MODEL_PROVIDER: {settings.ai_model_provider}")
