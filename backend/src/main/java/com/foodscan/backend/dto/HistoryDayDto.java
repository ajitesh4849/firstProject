package com.foodscan.backend.dto;

import java.time.LocalDate;

public record HistoryDayDto(String label, int calories, LocalDate date) {
}
