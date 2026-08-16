from pydantic import BaseModel, Field


class PredictResponse(BaseModel):
    foodName: str = Field(..., min_length=1)
    confidence: float = Field(..., ge=0.0, le=1.0)


class LabelReadResponse(BaseModel):
    productName: str = Field(..., min_length=1)
    brand: str | None = None
    ingredientsText: str = Field(..., min_length=1)
    confidence: float = Field(..., ge=0.0, le=1.0)


class HealthResponse(BaseModel):
    status: str
    service: str
    provider: str
