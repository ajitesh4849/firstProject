package com.foodscan.backend.dto;

public record ApiErrorResponse(
        String code,
        String message,
        Object details
) {
}
