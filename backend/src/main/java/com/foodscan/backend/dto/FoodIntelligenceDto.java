package com.foodscan.backend.dto;

import java.util.List;

/**
 * Shared "score → personalize → improve" payload for meal and packaged results.
 */
public record FoodIntelligenceDto(
        int healthScore,
        /** EXCELLENT | GOOD | MODERATE | OCCASIONAL | POOR */
        String healthBand,
        List<AnalysisPointDto> good,
        List<AnalysisPointDto> watch,
        int personalizedScore,
        String personalizedVerdict,
        String goal,
        List<AlternativeDto> alternatives
) {
}
