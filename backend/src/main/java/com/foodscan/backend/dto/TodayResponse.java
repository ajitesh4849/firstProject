package com.foodscan.backend.dto;

import java.util.List;

public record TodayResponse(
        int consumedKcal,
        int goalKcal,
        double consumedProteinGrams,
        double goalProteinGrams,
        double consumedCarbsGrams,
        double goalCarbsGrams,
        double consumedFatGrams,
        double goalFatGrams,
        double consumedFibreGrams,
        double goalFibreGrams,
        double consumedSugarGrams,
        double goalSugarGrams,
        String goal,
        List<MealDto> meals
) {
}
