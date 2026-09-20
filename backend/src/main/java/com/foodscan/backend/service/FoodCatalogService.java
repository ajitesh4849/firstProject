package com.foodscan.backend.service;

import com.foodscan.backend.dto.FoodIntelligenceDto;
import com.foodscan.backend.dto.FoodSearchItemDto;
import com.foodscan.backend.dto.NutritionResponse;
import com.foodscan.backend.entity.UserAccount;
import com.foodscan.backend.exception.NotFoundException;
import com.foodscan.backend.intelligence.FoodIntelligenceService;
import com.foodscan.backend.nutrition.FoodNutritionCache;
import com.foodscan.backend.nutrition.MacroProfile;
import com.foodscan.backend.repository.UserAccountRepository;
import com.foodscan.backend.security.CurrentUserService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class FoodCatalogService {

    private final FoodNutritionCache cache;
    private final FoodIntelligenceService foodIntelligenceService;
    private final CurrentUserService currentUserService;
    private final UserAccountRepository userAccountRepository;

    public FoodCatalogService(
            FoodNutritionCache cache,
            FoodIntelligenceService foodIntelligenceService,
            CurrentUserService currentUserService,
            UserAccountRepository userAccountRepository
    ) {
        this.cache = cache;
        this.foodIntelligenceService = foodIntelligenceService;
        this.currentUserService = currentUserService;
        this.userAccountRepository = userAccountRepository;
    }

    public List<FoodSearchItemDto> search(String query, int limit) {
        return cache.search(query, limit).stream()
                .map(e -> new FoodSearchItemDto(
                        e.name(),
                        e.category(),
                        e.profile().caloriesPer100g(),
                        e.profile().proteinPer100g(),
                        e.profile().carbsPer100g(),
                        e.profile().fatPer100g(),
                        e.profile().fibrePer100g(),
                        e.profile().sugarPer100g()
                ))
                .toList();
    }

    public NutritionResponse nutritionFor(String name, int portionGrams) {
        int grams = Math.max(1, Math.min(portionGrams, 2000));
        FoodNutritionCache.FoodCatalogEntry entry = cache.findEntry(name)
                .orElseThrow(() -> new NotFoundException("Food not found: " + name));
        MacroProfile profile = entry.profile();
        double factor = grams / 100.0;

        int calories = (int) Math.round(profile.caloriesPer100g() * factor);
        double protein = round1(profile.proteinPer100g() * factor);
        double carbs = round1(profile.carbsPer100g() * factor);
        double fat = round1(profile.fatPer100g() * factor);
        double fibre = round1(profile.fibrePer100g() * factor);
        double sugar = round1(profile.sugarPer100g() * factor);
        double sodium = round1(profile.sodiumMgPer100g() * factor);

        String goal = currentUserGoal();
        FoodIntelligenceDto intelligence = foodIntelligenceService.forMeal(
                entry.name(),
                calories,
                protein,
                carbs,
                fat,
                fibre,
                sugar,
                sodium,
                grams,
                goal
        );

        return new NutritionResponse(
                entry.name(),
                grams,
                calories,
                protein,
                carbs,
                fat,
                fibre,
                sugar,
                sodium,
                true,
                intelligence
        );
    }

    private String currentUserGoal() {
        try {
            UUID userId = currentUserService.requireUserId();
            return userAccountRepository.findById(userId)
                    .map(UserAccount::getGoal)
                    .orElse("LOSE_WEIGHT");
        } catch (RuntimeException ex) {
            return "LOSE_WEIGHT";
        }
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
