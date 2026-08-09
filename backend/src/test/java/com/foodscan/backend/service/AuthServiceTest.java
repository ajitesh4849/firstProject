package com.foodscan.backend.service;

import com.foodscan.backend.dto.LoginRequest;
import com.foodscan.backend.dto.SignupRequest;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.repository.UserAccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@ActiveProfiles("test")
class AuthServiceTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserAccountRepository userAccountRepository;

    @BeforeEach
    void clean() {
        userAccountRepository.deleteAll();
    }

    @Test
    void signupAndLoginReturnsToken() {
        authService.signup(new SignupRequest("user@example.com", "secret123"));
        var response = authService.login(new LoginRequest("user@example.com", "secret123"));
        assertNotNull(response.accessToken());
        assertTrue(response.accessToken().length() > 20);
    }

    @Test
    void signupNormalizesEmailAndRejectsDuplicate() {
        authService.signup(new SignupRequest("User@Example.com", "secret123"));
        assertThrows(
                BadRequestException.class,
                () -> authService.signup(new SignupRequest("user@example.com", "secret123"))
        );
    }

    @Test
    void loginRejectsBadPassword() {
        authService.signup(new SignupRequest("user@example.com", "secret123"));
        assertThrows(
                BadRequestException.class,
                () -> authService.login(new LoginRequest("user@example.com", "fail"))
        );
    }
}
