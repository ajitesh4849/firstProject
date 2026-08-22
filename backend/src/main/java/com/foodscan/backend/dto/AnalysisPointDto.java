package com.foodscan.backend.dto;

/**
 * GOOD or WATCH point with a short evidence-style explanation.
 */
public record AnalysisPointDto(
        String title,
        String detail,
        /** GOOD | WATCH */
        String kind
) {
}
