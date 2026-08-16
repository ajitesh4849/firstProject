from fastapi import Depends, FastAPI, File, HTTPException, UploadFile, status

from app.adapters.base import FoodRecognitionAdapter
from app.adapters.factory import build_adapter
from app.config import Settings, get_settings
from app.schemas import HealthResponse, LabelReadResponse, PredictResponse

app = FastAPI(
    title="FoodScan AI Service",
    description="Internal food recognition service. Called only by Spring Boot.",
    version="0.1.0",
)


def get_adapter(settings: Settings = Depends(get_settings)) -> FoodRecognitionAdapter:
    try:
        return build_adapter(settings)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(exc)) from exc


async def _read_validated_image(
    image: UploadFile,
    settings: Settings,
) -> tuple[bytes, str]:
    content_type = (image.content_type or "").lower()
    allowed = {item.strip() for item in settings.allowed_image_types.split(",") if item.strip()}
    if content_type not in allowed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported image type '{content_type}'. Allowed: {', '.join(sorted(allowed))}",
        )

    image_bytes = await image.read()
    if not image_bytes:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Image file is empty")
    if len(image_bytes) > settings.max_image_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Image exceeds max size of {settings.max_image_bytes} bytes",
        )
    return image_bytes, content_type


@app.get("/health", response_model=HealthResponse)
async def health(settings: Settings = Depends(get_settings)) -> HealthResponse:
    return HealthResponse(
        status="UP",
        service="foodscan-ai",
        provider=settings.ai_model_provider,
    )


@app.post("/predict", response_model=PredictResponse)
async def predict(
    image: UploadFile = File(...),
    settings: Settings = Depends(get_settings),
    adapter: FoodRecognitionAdapter = Depends(get_adapter),
) -> PredictResponse:
    image_bytes, content_type = await _read_validated_image(image, settings)

    try:
        return await adapter.predict(image_bytes, content_type, image.filename)
    except NotImplementedError as exc:
        raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001 - surface useful internal failure to caller
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Food recognition failed: {exc}",
        ) from exc


@app.post("/read-label", response_model=LabelReadResponse)
async def read_label(
    image: UploadFile = File(...),
    settings: Settings = Depends(get_settings),
    adapter: FoodRecognitionAdapter = Depends(get_adapter),
) -> LabelReadResponse:
    image_bytes, content_type = await _read_validated_image(image, settings)

    try:
        result = await adapter.read_label(image_bytes, content_type, image.filename)
        if not result.ingredientsText.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Could not read ingredients from this photo. Try a clearer close-up of the label.",
            )
        return result
    except HTTPException:
        raise
    except NotImplementedError as exc:
        raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Label reading failed: {exc}",
        ) from exc
