package com.foodscan.backend.dto;

public record NutritionResponse(
        String foodName,
        int portionGrams,
        int calories,
        double proteinGrams,
        double carbsGrams,
        double fatGrams,
        boolean estimated
) {
}
