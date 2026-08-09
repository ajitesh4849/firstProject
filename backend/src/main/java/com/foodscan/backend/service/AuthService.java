package com.foodscan.backend.service;

import com.foodscan.backend.dto.LoginRequest;
import com.foodscan.backend.dto.LoginResponse;
import com.foodscan.backend.dto.UserDto;
import com.foodscan.backend.exception.BadRequestException;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuthService {

    public LoginResponse login(LoginRequest request) {
        if ("fail".equalsIgnoreCase(request.password())) {
            throw new BadRequestException("Invalid email or password");
        }

        return new LoginResponse(
                "mock-token-" + UUID.randomUUID(),
                new UserDto("user-1", request.email())
        );
    }
}
