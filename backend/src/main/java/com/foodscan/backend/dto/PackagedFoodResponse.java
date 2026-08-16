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
        String score,
        int riskCount,
        List<PackagedRiskFlagDto> flags,
        List<String> healthierSwaps,
        String disclaimer,
        boolean found
) {
}
