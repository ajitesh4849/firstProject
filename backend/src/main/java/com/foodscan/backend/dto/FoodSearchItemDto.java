package com.foodscan.backend.dto;

public record FoodSearchItemDto(
        String name,
        String category,
        int caloriesPer100g,
        double proteinPer100g,
        double carbsPer100g,
        double fatPer100g,
        double fibrePer100g,
        double sugarPer100g
) {
}
