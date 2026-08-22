package com.foodscan.backend.nutrition;

/**
 * Macronutrients and calories per 100 grams (approximate).
 */
public record MacroProfile(
        int caloriesPer100g,
        double proteinPer100g,
        double carbsPer100g,
        double fatPer100g,
        double fibrePer100g,
        double sugarPer100g,
        double sodiumMgPer100g
) {
    /** Convenience when fibre/sugar/sodium are unknown — uses light defaults. */
    public MacroProfile(int caloriesPer100g, double proteinPer100g, double carbsPer100g, double fatPer100g) {
        this(
                caloriesPer100g,
                proteinPer100g,
                carbsPer100g,
                fatPer100g,
                Math.max(1.0, carbsPer100g * 0.08),
                Math.max(1.0, carbsPer100g * 0.15),
                180
        );
    }
}
