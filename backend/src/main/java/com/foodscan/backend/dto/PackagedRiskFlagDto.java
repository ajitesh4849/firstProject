package com.foodscan.backend.dto;

import java.util.List;

public record PackagedRiskFlagDto(
        String code,
        String title,
        String severity,
        String detail
) {
}
