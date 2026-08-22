package com.foodscan.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record SavePackagedSeedRequest(
        @NotBlank
        @Pattern(regexp = "\\d{8,14}", message = "Barcode must be 8–14 digits")
        String barcode,

        @NotBlank
        @Size(max = 255)
        String productName,

        @Size(max = 255)
        String brand,

        @Size(max = 64)
        String quantity,

        /** Optional — Open Food Facts sometimes has no ingredients text. */
        @Size(max = 8000)
        String ingredientsText,

        Double sugarPer100g,
        Double saltPer100g,
        Double energyKcalPer100g
) {
}
