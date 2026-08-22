package com.foodscan.backend.dto;

import java.util.List;

public record PackagedFoodResponse(
        String barcode,
        String productName,
        String brand,
        String quantity,
        String ingredientsText,
        Double sugarPer100g,
        Double saltPer100g,
        Double energyKcalPer100g,
        Double proteinPer100g,
        Double carbsPer100g,
        Double fatPer100g,
        Double fibrePer100g,
        Double saturatedFatPer100g,
        Double sodiumMgPer100g,
        /** Legacy band: BETTER | OK | CAUTION — derived from healthScore */
        String score,
        int riskCount,
        List<PackagedRiskFlagDto> flags,
        List<String> healthierSwaps,
        String disclaimer,
        boolean found,
        /** SEED | OPEN_FOOD_FACTS | LABEL_PHOTO */
        String source,
        /** True when result can be saved into the local catalog (valid barcode). */
        boolean canSaveToCatalog,
        List<PackagedIngredientMarkDto> ingredients,
        FoodIntelligenceDto intelligence
) {
}
