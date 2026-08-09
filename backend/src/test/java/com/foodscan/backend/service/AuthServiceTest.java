package com.foodscan.backend.service;

import com.foodscan.backend.dto.LoginRequest;
import com.foodscan.backend.dto.LoginResponse;
import com.foodscan.backend.exception.BadRequestException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AuthServiceTest {

    private final AuthService authService = new AuthService();

    @Test
    void loginReturnsToken() {
        LoginResponse response = authService.login(new LoginRequest("user@example.com", "secret"));
        assertNotNull(response.accessToken());
        assertEquals("user@example.com", response.user().email());
        assertTrue(response.accessToken().startsWith("mock-token-"));
    }

    @Test
    void loginRejectsFailPassword() {
        assertThrows(
                BadRequestException.class,
                () -> authService.login(new LoginRequest("user@example.com", "fail"))
        );
    }
}
