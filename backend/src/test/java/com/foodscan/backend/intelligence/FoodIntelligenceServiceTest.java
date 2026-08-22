package com.foodscan.backend.intelligence;

import com.foodscan.backend.dto.FoodIntelligenceDto;
import com.foodscan.backend.dto.PackagedRiskFlagDto;
import com.foodscan.backend.packaged.OpenFoodFactsProduct;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class FoodIntelligenceServiceTest {

    private final FoodIntelligenceService service = new FoodIntelligenceService();

    @Test
    void mealScoreRewardsProteinAndFibre() {
        FoodIntelligenceDto result = service.forMeal(
                "Grilled chicken",
                250,
                40,
                5,
                8,
                0,
                1,
                300,
                150,
                "GAIN_MUSCLE"
        );
        assertTrue(result.healthScore() >= 70);
        assertTrue(result.personalizedScore() >= result.healthScore());
        assertFalse(result.alternatives().isEmpty());
        assertEquals("GAIN_MUSCLE", result.goal());
    }

    @Test
    void loseWeightPenalizesHighCalorieMeals() {
        FoodIntelligenceDto result = service.forMeal(
                "Chicken biryani",
                700,
                18,
                90,
                22,
                3,
                4,
                500,
                350,
                "LOSE_WEIGHT"
        );
        assertTrue(result.personalizedScore() <= result.healthScore());
        assertTrue(result.watch().stream().anyMatch(w -> w.title().toLowerCase().contains("calorie")));
    }

    @Test
    void packagedScoreUsesFlags() {
        OpenFoodFactsProduct product = new OpenFoodFactsProduct(
                "890123",
                "Test Chips",
                "Brand",
                "100g",
                "potato, palm oil, sugar",
                "Snacks, Chips",
                25.0,
                1.8,
                520.0,
                5.0,
                50.0,
                30.0,
                2.0,
                10.0,
                720.0,
                true
        );
        FoodIntelligenceDto result = service.forPackaged(
                product,
                List.of(new PackagedRiskFlagDto("sugar", "High sugar", "high", "too sweet")),
                List.of(),
                "LOSE_WEIGHT"
        );
        assertTrue(result.healthScore() < 82);
        assertFalse(result.alternatives().isEmpty());
        assertTrue(result.watch().stream().anyMatch(w -> w.title().contains("sugar") || w.title().contains("Sugar")));
    }
}
