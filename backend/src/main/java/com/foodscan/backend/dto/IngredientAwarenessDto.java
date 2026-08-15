package com.foodscan.backend.dto;

import java.util.List;

public record IngredientAwarenessDto(
        String category,
        List<String> likelyAdditives,
        List<String> healthierSwaps,
        String disclaimer
) {
}
