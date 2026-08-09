package com.foodscan.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AddMealRequest(
        @NotBlank String foodName,
        @NotNull @Min(1) Integer portionGrams,
        @NotNull @Min(0) Integer calories,
        @NotNull @Min(0) Double proteinGrams,
        @NotNull @Min(0) Double carbsGrams,
        @NotNull @Min(0) Double fatGrams
) {
}
