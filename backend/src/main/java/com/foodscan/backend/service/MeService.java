package com.foodscan.backend.service;

import com.foodscan.backend.dto.AddMealRequest;
import com.foodscan.backend.dto.HistoryDayDto;
import com.foodscan.backend.dto.HistoryResponse;
import com.foodscan.backend.dto.MealDto;
import com.foodscan.backend.dto.ProfileResponse;
import com.foodscan.backend.dto.TodayResponse;
import com.foodscan.backend.dto.UpdateProfileRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class MeService {

    private static final int GOAL_KCAL = 2200;

    private final List<MealDto> todayMeals = new CopyOnWriteArrayList<>(List.of(
            new MealDto("Breakfast", 450),
            new MealDto("Lunch", 680),
            new MealDto("Dinner", 720)
    ));

    private ProfileResponse profile = new ProfileResponse(30, 70, 170, "LOSE_WEIGHT");

    public TodayResponse today() {
        int consumed = todayMeals.stream().mapToInt(MealDto::calories).sum();
        return new TodayResponse(consumed, GOAL_KCAL, List.copyOf(todayMeals));
    }

    public MealDto addMeal(AddMealRequest request) {
        MealDto meal = new MealDto(request.foodName(), request.calories());
        todayMeals.add(meal);
        return meal;
    }

    public HistoryResponse history() {
        List<HistoryDayDto> days = new ArrayList<>();
        days.add(new HistoryDayDto("Mon", 1900, LocalDate.of(2026, 8, 3)));
        days.add(new HistoryDayDto("Tue", 2100, LocalDate.of(2026, 8, 4)));
        days.add(new HistoryDayDto("Wed", 1750, LocalDate.of(2026, 8, 5)));
        days.add(new HistoryDayDto("Thu", 2000, LocalDate.of(2026, 8, 6)));
        days.add(new HistoryDayDto("Fri", 1850, LocalDate.of(2026, 8, 7)));
        days.add(new HistoryDayDto("Sat", 2300, LocalDate.of(2026, 8, 8)));
        days.add(new HistoryDayDto("Sun", 1850, LocalDate.of(2026, 8, 9)));

        double average = days.stream().mapToInt(HistoryDayDto::calories).average().orElse(0);
        return new HistoryResponse(days, average);
    }

    public ProfileResponse getProfile() {
        return profile;
    }

    public ProfileResponse updateProfile(UpdateProfileRequest request) {
        profile = new ProfileResponse(
                request.age(),
                request.weightKg(),
                request.heightCm(),
                request.goal()
        );
        return profile;
    }
}
