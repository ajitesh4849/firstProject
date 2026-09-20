package com.foodscan.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @NotNull @Min(10) @Max(120) Integer age,
        @NotNull @Min(20) @Max(400) Double weightKg,
        @NotNull @Min(80) @Max(250) Double heightCm,
        @NotBlank String gender,
        @NotBlank String activityLevel,
        @NotBlank String goal,
        @Size(max = 32) String dietPreference,
        @Size(max = 128) String allergens
) {
}
