package com.foodscan.backend.dto;

public record AiPredictResponse(String foodName, double confidence) {
}
