package com.foodscan.backend.nutrition;

/**
 * Macronutrients and calories per 100 grams.
 */
public record MacroProfile(
        int caloriesPer100g,
        double proteinPer100g,
        double carbsPer100g,
        double fatPer100g
) {
}
