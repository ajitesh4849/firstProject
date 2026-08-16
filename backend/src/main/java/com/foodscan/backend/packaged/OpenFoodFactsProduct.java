package com.foodscan.backend.packaged;

import java.util.List;

public record OpenFoodFactsProduct(
        String barcode,
        String productName,
        String brand,
        String quantity,
        String ingredientsText,
        String categories,
        Double sugarPer100g,
        Double saltPer100g,
        Double energyKcalPer100g,
        boolean found
) {
    public static OpenFoodFactsProduct notFound(String barcode) {
        return new OpenFoodFactsProduct(barcode, null, null, null, null, null, null, null, null, false);
    }
}
