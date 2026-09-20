package com.foodscan.backend.dto;

public record FoodCandidateDto(
        String foodName,
        double confidence,
        String category
) {
}
