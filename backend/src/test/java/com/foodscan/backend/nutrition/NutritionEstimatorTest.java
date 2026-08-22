package com.foodscan.backend.nutrition;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class NutritionEstimatorTest {

    private final NutritionEstimator estimator = new NutritionEstimator();

    @Test
    void usesKeywordHeuristicsWhenCacheEmpty() {
        MacroProfile salad = estimator.estimateFor("Mixed Green Salad Bowl");
        assertTrue(salad.caloriesPer100g() < 100);
    }

    @Test
    void dosaKeywordMatch() {
        MacroProfile dosa = estimator.estimateFor("Masala Dosa");
        assertEquals(170, dosa.caloriesPer100g());
        assertEquals(4.0, dosa.proteinPer100g());
    }

    @Test
    void fallsBackForUnknownFood() {
        MacroProfile unknown = estimator.estimateFor("Mystery Space Stew");
        assertEquals(180, unknown.caloriesPer100g());
    }
}
