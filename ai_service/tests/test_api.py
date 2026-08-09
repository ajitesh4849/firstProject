from io import BytesIO

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


def test_health(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "UP"
    assert body["service"] == "foodscan-ai"
    assert body["provider"] == "mock"


def test_predict_success(client: TestClient) -> None:
    files = {"image": ("meal.jpg", BytesIO(b"fake-image-bytes-12345"), "image/jpeg")}
    response = client.post("/predict", files=files)
    assert response.status_code == 200
    body = response.json()
    assert body["foodName"]
    assert 0.0 <= body["confidence"] <= 1.0


def test_predict_rejects_non_image(client: TestClient) -> None:
    files = {"image": ("notes.txt", BytesIO(b"hello"), "text/plain")}
    response = client.post("/predict", files=files)
    assert response.status_code == 400


def test_predict_rejects_empty(client: TestClient) -> None:
    files = {"image": ("empty.jpg", BytesIO(b""), "image/jpeg")}
    response = client.post("/predict", files=files)
    assert response.status_code == 400
