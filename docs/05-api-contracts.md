# FoodScan – Initial API Contracts

These are initial contracts for integration after UI is complete.

**Primary API consumer:** Flutter mobile app.

The Next.js marketing website should **not** call scan, meal, today, history, or profile APIs in MVP. It may later call a contact (or similar) endpoint if added.

## POST /api/v1/auth/login

Request:

```json
{
  "email": "user@example.com",
  "password": "********"
}
```

Response:

```json
{
  "accessToken": "token",
  "user": {
    "id": "user-id",
    "email": "user@example.com"
  }
}
```

## POST /api/v1/scans

Multipart request:
- image: food image

Response:

```json
{
  "scanId": "scan-123",
  "food": {
    "name": "Paneer Butter Masala",
    "confidence": 0.92
  }
}
```

## POST /api/v1/scans/{scanId}/nutrition

Request:

```json
{
  "portionGrams": 200
}
```

Response:

```json
{
  "foodName": "Paneer Butter Masala",
  "portionGrams": 200,
  "calories": 380,
  "proteinGrams": 14,
  "carbsGrams": 12,
  "fatGrams": 30,
  "estimated": true
}
```

## POST /api/v1/meals

Adds a nutrition result to today's intake.

## GET /api/v1/me/today

Returns today's calorie total and meals.

## GET /api/v1/me/history

Returns historical calorie summaries.

## GET /api/v1/me/profile

Returns user profile and goals.

## PUT /api/v1/me/profile

Updates profile and goals.

## AI Contract (internal)

### POST /predict

Multipart:
- image

Response:

```json
{
  "foodName": "Paneer Butter Masala",
  "confidence": 0.92
}
```

The AI service is internal and should not be exposed directly to clients.
Spring Boot is the only caller of `/predict`.
