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
import com.foodscan.backend.exception.BadRequestException;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.nutrition.DailyCalorieGoalCalculator;
import com.foodscan.backend.nutrition.DailyMacroGoals;
import com.foodscan.backend.repository.MealEntryRepository;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MeService {

    private static final Set<String> ALLOWED_GOALS = Set.of(
            "LOSE_WEIGHT",
            "MAINTAIN",
            "GAIN_MUSCLE"
    );

    private static final Set<String> ALLOWED_GENDERS = Set.of(
            "MALE",
            "FEMALE",
            "UNSPECIFIED"
    );

    private static final Set<String> ALLOWED_ACTIVITY_LEVELS = Set.of(
            "SEDENTARY",
            "LIGHTLY_ACTIVE",
            "MODERATELY_ACTIVE",
            "VERY_ACTIVE"
    );

    private final CurrentUserService currentUserService;
    private final UserAccountRepository userAccountRepository;
    private final MealEntryRepository mealEntryRepository;
    private final DailyCalorieGoalCalculator dailyCalorieGoalCalculator;

    public MeService(
            CurrentUserService currentUserService,
            UserAccountRepository userAccountRepository,
            MealEntryRepository mealEntryRepository,
            DailyCalorieGoalCalculator dailyCalorieGoalCalculator
    ) {
        this.currentUserService = currentUserService;
        this.userAccountRepository = userAccountRepository;
        this.mealEntryRepository = mealEntryRepository;
        this.dailyCalorieGoalCalculator = dailyCalorieGoalCalculator;
    }

    @Transactional(readOnly = true)
    public TodayResponse today() {
        UserAccount user = requireUser();
        LocalDate today = LocalDate.now();
        List<MealEntry> meals = mealEntryRepository.findByUserIdAndMealDateOrderByCreatedAtAsc(user.getId(), today);
        int consumed = meals.stream().mapToInt(MealEntry::getCalories).sum();
        double protein = meals.stream().mapToDouble(m -> nz(m.getProteinGrams())).sum();
        double carbs = meals.stream().mapToDouble(m -> nz(m.getCarbsGrams())).sum();
        double fat = meals.stream().mapToDouble(m -> nz(m.getFatGrams())).sum();
        double fibre = meals.stream().mapToDouble(m -> nz(m.getFibreGrams())).sum();
        double sugar = meals.stream().mapToDouble(m -> nz(m.getSugarGrams())).sum();
        DailyMacroGoals.Targets targets = DailyMacroGoals.fromCalorieGoal(user.getDailyGoalKcal());
        List<MealDto> mealDtos = meals.stream()
                .map(meal -> new MealDto(meal.getFoodName(), meal.getCalories()))
                .toList();
        return new TodayResponse(
                consumed,
                user.getDailyGoalKcal(),
                round1(protein),
                targets.proteinGrams(),
                round1(carbs),
                targets.carbsGrams(),
                round1(fat),
                targets.fatGrams(),
                round1(fibre),
                targets.fibreGrams(),
                round1(sugar),
                targets.sugarGrams(),
                user.getGoal() == null ? "LOSE_WEIGHT" : user.getGoal(),
                mealDtos
        );
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
        meal.setFibreGrams(request.fibreGrams() == null ? 0.0 : request.fibreGrams());
        meal.setSugarGrams(request.sugarGrams() == null ? 0.0 : request.sugarGrams());
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
        return toProfileResponse(requireUser());
    }

    @Transactional
    public ProfileResponse updateProfile(UpdateProfileRequest request) {
        UserAccount user = requireUser();

        String goal = normalize(request.goal());
        String gender = normalize(request.gender());
        String activityLevel = normalize(request.activityLevel());

        if (!ALLOWED_GOALS.contains(goal)) {
            throw new BadRequestException("Invalid goal. Use LOSE_WEIGHT, MAINTAIN, or GAIN_MUSCLE");
        }
        if (!ALLOWED_GENDERS.contains(gender)) {
            throw new BadRequestException("Invalid gender. Use MALE, FEMALE, or UNSPECIFIED");
        }
        if (!ALLOWED_ACTIVITY_LEVELS.contains(activityLevel)) {
            throw new BadRequestException(
                    "Invalid activity level. Use SEDENTARY, LIGHTLY_ACTIVE, MODERATELY_ACTIVE, or VERY_ACTIVE"
            );
        }

        user.setAge(request.age());
        user.setWeightKg(request.weightKg());
        user.setHeightCm(request.heightCm());
        user.setGender(gender);
        user.setActivityLevel(activityLevel);
        user.setGoal(goal);
        user.setDailyGoalKcal(
                dailyCalorieGoalCalculator.calculate(
                        request.age(),
                        request.weightKg(),
                        request.heightCm(),
                        gender,
                        activityLevel,
                        goal
                )
        );
        userAccountRepository.save(user);
        return toProfileResponse(user);
    }

    private ProfileResponse toProfileResponse(UserAccount user) {
        String gender = user.getGender() == null || user.getGender().isBlank()
                ? "UNSPECIFIED"
                : user.getGender();
        String activity = user.getActivityLevel() == null || user.getActivityLevel().isBlank()
                ? "SEDENTARY"
                : user.getActivityLevel();
        return new ProfileResponse(
                user.getAge(),
                user.getWeightKg(),
                user.getHeightCm(),
                gender,
                activity,
                user.getGoal(),
                user.getDailyGoalKcal()
        );
    }

    private UserAccount requireUser() {
        UUID userId = currentUserService.requireUserId();
        return userAccountRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }

    private static String normalize(String value) {
        return value == null ? "" : value.trim().toUpperCase(Locale.ENGLISH);
    }

    private static double nz(Double value) {
        return value == null ? 0.0 : value;
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
