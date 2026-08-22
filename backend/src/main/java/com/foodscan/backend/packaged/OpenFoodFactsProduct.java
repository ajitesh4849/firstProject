package com.foodscan.backend.packaged;

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
        Double proteinPer100g,
        Double carbsPer100g,
        Double fatPer100g,
        Double fibrePer100g,
        Double saturatedFatPer100g,
        Double sodiumMgPer100g,
        boolean found
) {
    public static OpenFoodFactsProduct notFound(String barcode) {
        return new OpenFoodFactsProduct(
                barcode, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null,
                false
        );
    }
}
