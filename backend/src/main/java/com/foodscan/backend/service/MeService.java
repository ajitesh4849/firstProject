package com.foodscan.backend.service;

import com.foodscan.backend.dto.AddMealRequest;
import com.foodscan.backend.dto.HistoryDayDto;
import com.foodscan.backend.dto.HistoryResponse;
import com.foodscan.backend.dto.MealDto;
import com.foodscan.backend.dto.ProfileResponse;
import com.foodscan.backend.dto.TodayResponse;
import com.foodscan.backend.dto.UpdateProfileRequest;
import com.foodscan.backend.entity.MealEntry;
import com.foodscan.backend.entity.UserAccount;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.repository.MealEntryRepository;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MeService {

    private final CurrentUserService currentUserService;
    private final UserAccountRepository userAccountRepository;
    private final MealEntryRepository mealEntryRepository;

    public MeService(
            CurrentUserService currentUserService,
            UserAccountRepository userAccountRepository,
            MealEntryRepository mealEntryRepository
    ) {
        this.currentUserService = currentUserService;
        this.userAccountRepository = userAccountRepository;
        this.mealEntryRepository = mealEntryRepository;
    }

    @Transactional(readOnly = true)
    public TodayResponse today() {
        UserAccount user = requireUser();
        LocalDate today = LocalDate.now();
        List<MealEntry> meals = mealEntryRepository.findByUserIdAndMealDateOrderByCreatedAtAsc(user.getId(), today);
        int consumed = meals.stream().mapToInt(MealEntry::getCalories).sum();
        List<MealDto> mealDtos = meals.stream()
                .map(meal -> new MealDto(meal.getFoodName(), meal.getCalories()))
                .toList();
        return new TodayResponse(consumed, user.getDailyGoalKcal(), mealDtos);
    }

    @Transactional
    public MealDto addMeal(AddMealRequest request) {
        UUID userId = currentUserService.requireUserId();
        MealEntry meal = new MealEntry();
        meal.setUserId(userId);
        meal.setFoodName(request.foodName());
        meal.setPortionGrams(request.portionGrams());
        meal.setCalories(request.calories());
        meal.setProteinGrams(request.proteinGrams());
        meal.setCarbsGrams(request.carbsGrams());
        meal.setFatGrams(request.fatGrams());
        meal.setMealDate(LocalDate.now());
        mealEntryRepository.save(meal);
        return new MealDto(meal.getFoodName(), meal.getCalories());
    }

    @Transactional(readOnly = true)
    public HistoryResponse history() {
        UUID userId = currentUserService.requireUserId();
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(6);

        List<MealEntry> meals = mealEntryRepository.findByUserIdAndMealDateBetweenOrderByMealDateAsc(
                userId,
                start,
                end
        );

        Map<LocalDate, Integer> caloriesByDate = meals.stream()
                .collect(Collectors.groupingBy(
                        MealEntry::getMealDate,
                        Collectors.summingInt(MealEntry::getCalories)
                ));

        List<HistoryDayDto> days = new ArrayList<>();
        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            String label = date.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
            days.add(new HistoryDayDto(label, caloriesByDate.getOrDefault(date, 0), date));
        }

        double average = days.stream().mapToInt(HistoryDayDto::calories).average().orElse(0);
        return new HistoryResponse(days, average);
    }

    @Transactional(readOnly = true)
    public ProfileResponse getProfile() {
        UserAccount user = requireUser();
        return new ProfileResponse(
                user.getAge(),
                user.getWeightKg(),
                user.getHeightCm(),
                user.getGoal()
        );
    }

    @Transactional
    public ProfileResponse updateProfile(UpdateProfileRequest request) {
        UserAccount user = requireUser();
        user.setAge(request.age());
        user.setWeightKg(request.weightKg());
        user.setHeightCm(request.heightCm());
        user.setGoal(request.goal());
        userAccountRepository.save(user);
        return getProfile();
    }

    private UserAccount requireUser() {
        UUID userId = currentUserService.requireUserId();
        return userAccountRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }
}
