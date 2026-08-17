package com.foodscan.backend.dto;

public record PackagedIngredientMarkDto(
        String text,
        /** UNHEALTHY | HEALTHIER | NEUTRAL */
        String tag,
        String reason
) {
}
