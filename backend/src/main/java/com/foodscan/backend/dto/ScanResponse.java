package com.foodscan.backend.dto;

import java.util.List;

public record ScanResponse(
        String scanId,
        FoodDto food,
        List<FoodCandidateDto> candidates,
        String identifierMode,
        boolean needsUserPick
) {
}
