package com.foodscan.backend.packaged;

import com.foodscan.backend.dto.PackagedRiskFlagDto;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PackagedFoodRiskAnalyzerTest {

    private final PackagedFoodRiskAnalyzer analyzer = new PackagedFoodRiskAnalyzer();

    @Test
    void flagsArtificialColorsAndHighSugar() {
        OpenFoodFactsProduct product = new OpenFoodFactsProduct(
                "12345678",
                "Fruit Drink",
                "TestBrand",
                "500ml",
                "Water, sugar, E110, E211",
                "Beverages, Soft drinks",
                28.0,
                0.1,
                120.0,
                true
        );

        PackagedFoodRiskAnalyzer.AnalysisResult result = analyzer.analyze(product);
        assertEquals("CAUTION", result.score());
        assertTrue(result.flags().stream().anyMatch(f -> f.code().contains("110") || f.title().toLowerCase().contains("color")));
        assertTrue(result.flags().stream().anyMatch(f -> "HIGH_SUGAR".equals(f.code())));
        assertTrue(result.healthierSwaps().size() >= 1);
    }

    @Test
    void betterScoreWhenClean() {
        OpenFoodFactsProduct product = new OpenFoodFactsProduct(
                "12345678",
                "Rolled Oats",
                "TestBrand",
                "1kg",
                "Whole grain oats",
                "Breakfast cereals",
                1.0,
                0.01,
                370.0,
                true
        );

        PackagedFoodRiskAnalyzer.AnalysisResult result = analyzer.analyze(product);
        assertEquals("BETTER", result.score());
        List<PackagedRiskFlagDto> flags = result.flags();
        assertTrue(flags.isEmpty());
    }
}
