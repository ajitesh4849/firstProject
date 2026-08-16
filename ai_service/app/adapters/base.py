from abc import ABC, abstractmethod

from app.schemas import LabelReadResponse, PredictResponse


class FoodRecognitionAdapter(ABC):
    """Swap implementations without changing the /predict API contract."""

    @abstractmethod
    async def predict(self, image_bytes: bytes, content_type: str, filename: str | None) -> PredictResponse:
        raise NotImplementedError

    @abstractmethod
    async def read_label(
        self, image_bytes: bytes, content_type: str, filename: str | None
    ) -> LabelReadResponse:
        raise NotImplementedError
