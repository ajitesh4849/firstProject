package com.foodscan.backend.dto;

import java.util.List;

public record HistoryResponse(List<HistoryDayDto> days, double weeklyAverage) {
}
