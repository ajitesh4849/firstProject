package com.foodscan.backend.dto;

public record AllergyWarningDto(
        String code,
        String title,
        String detail
) {
}
