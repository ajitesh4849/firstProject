package com.foodscan.backend.dto;

public record FoodDto(
        String name,
        double confidence,
        IngredientAwarenessDto awareness
) {
}
