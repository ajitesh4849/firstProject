package com.foodscan.backend.dto;

import java.util.List;

public record NutritionResponse(
        String foodName,
        int portionGrams,
        int calories,
        double proteinGrams,
        double carbsGrams,
        double fatGrams,
        double fibreGrams,
        double sugarGrams,
        double sodiumMg,
        boolean estimated,
        FoodIntelligenceDto intelligence
) {
}
