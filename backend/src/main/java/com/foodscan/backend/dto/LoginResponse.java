package com.foodscan.backend.dto;

public record LoginResponse(String accessToken, UserDto user) {
}
