package com.foodscan.backend.controller;

import com.foodscan.backend.dto.AddMealRequest;
import com.foodscan.backend.dto.HistoryResponse;
import com.foodscan.backend.dto.MealDto;
import com.foodscan.backend.dto.ProfileResponse;
import com.foodscan.backend.dto.TodayResponse;
import com.foodscan.backend.dto.UpdateProfileRequest;
import com.foodscan.backend.service.MeService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class MeController {

    private final MeService meService;

    public MeController(MeService meService) {
        this.meService = meService;
    }

    @PostMapping("/meals")
    public ResponseEntity<MealDto> addMeal(@Valid @RequestBody AddMealRequest request) {
        return ResponseEntity.ok(meService.addMeal(request));
    }

    @GetMapping("/me/today")
    public ResponseEntity<TodayResponse> today() {
        return ResponseEntity.ok(meService.today());
    }

    @GetMapping("/me/history")
    public ResponseEntity<HistoryResponse> history() {
        return ResponseEntity.ok(meService.history());
    }

    @GetMapping("/me/profile")
    public ResponseEntity<ProfileResponse> getProfile() {
        return ResponseEntity.ok(meService.getProfile());
    }

    @PutMapping("/me/profile")
    public ResponseEntity<ProfileResponse> updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(meService.updateProfile(request));
    }
}
