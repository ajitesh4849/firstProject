package com.foodscan.backend.dto;

public record ProfileResponse(
        int age,
        double weightKg,
        double heightCm,
        String gender,
        String activityLevel,
        String goal,
        int dailyGoalKcal
) {
}
