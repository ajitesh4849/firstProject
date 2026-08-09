package com.foodscan.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record NutritionRequest(
        @NotNull @Min(1) @Max(5000) Integer portionGrams
) {
}
