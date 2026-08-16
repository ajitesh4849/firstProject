package com.foodscan.backend.dto;

public record AiLabelReadResponse(
        String productName,
        String brand,
        String ingredientsText,
        Double confidence
) {
}
