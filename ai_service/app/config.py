from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    ai_service_host: str = "0.0.0.0"
    ai_service_port: int = 8000
    ai_model_provider: str = "mock"
    openai_api_key: str | None = None
    openai_vision_model: str = "gpt-4o-mini"
    max_image_bytes: int = 8 * 1024 * 1024
    allowed_image_types: str = "image/jpeg,image/png,image/webp,image/gif"


@lru_cache
def get_settings() -> Settings:
    return Settings()
