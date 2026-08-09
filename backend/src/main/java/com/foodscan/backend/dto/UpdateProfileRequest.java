package com.foodscan.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record UpdateProfileRequest(
        @NotNull @Min(10) @Max(120) Integer age,
        @NotNull @Min(20) @Max(400) Double weightKg,
        @NotNull @Min(80) @Max(250) Double heightCm,
        @NotBlank String goal
) {
}
