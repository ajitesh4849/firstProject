package com.foodscan.backend.dto;

import java.util.List;

public record TodayResponse(int consumedKcal, int goalKcal, List<MealDto> meals) {
}
