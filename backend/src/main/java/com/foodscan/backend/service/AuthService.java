package com.foodscan.backend.service;

import com.foodscan.backend.dto.LoginRequest;
import com.foodscan.backend.dto.LoginResponse;
import com.foodscan.backend.dto.SignupRequest;
import com.foodscan.backend.dto.UserDto;
import com.foodscan.backend.entity.UserAccount;
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.nutrition.DailyCalorieGoalCalculator;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final DailyCalorieGoalCalculator dailyCalorieGoalCalculator;

    public AuthService(
            UserAccountRepository userAccountRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            DailyCalorieGoalCalculator dailyCalorieGoalCalculator
    ) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.dailyCalorieGoalCalculator = dailyCalorieGoalCalculator;
    }

    @Transactional
    public LoginResponse signup(SignupRequest request) {
        String email = normalizeEmail(request.email());
        if (email.isEmpty()) {
            throw new BadRequestException("Email is required");
        }
        if (userAccountRepository.existsByEmailIgnoreCase(email)) {
            throw new BadRequestException("Email is already registered");
        }

        UserAccount user = new UserAccount();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setDailyGoalKcal(
                dailyCalorieGoalCalculator.calculate(
                        user.getAge(),
                        user.getWeightKg(),
                        user.getHeightCm(),
                        user.getGender(),
                        user.getActivityLevel(),
                        user.getGoal()
                )
        );
        user = userAccountRepository.saveAndFlush(user);

        if (user.getId() == null) {
            throw new IllegalStateException("Failed to create user account");
        }

        return toLoginResponse(user);
    }

    public LoginResponse login(LoginRequest request) {
        String email = normalizeEmail(request.email());
        UserAccount user = userAccountRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new BadRequestException("Invalid email or password"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BadRequestException("Invalid email or password");
        }

        return toLoginResponse(user);
    }

    private LoginResponse toLoginResponse(UserAccount user) {
        String token = jwtService.generateToken(user.getId(), user.getEmail());
        return new LoginResponse(
                token,
                new UserDto(user.getId().toString(), user.getEmail())
        );
    }

    private static String normalizeEmail(String email) {
        return email == null ? "" : email.trim().toLowerCase();
    }
}
