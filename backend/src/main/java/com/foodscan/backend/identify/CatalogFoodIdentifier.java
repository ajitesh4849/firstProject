package com.foodscan.backend.identify;

import com.foodscan.backend.nutrition.FoodNutritionCache;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * No vision AI. Ranks catalog foods by real string-similarity to the user's hint.
 */
@Component
@ConditionalOnProperty(name = "foodscan.food-identifier", havingValue = "catalog", matchIfMissing = true)
public class CatalogFoodIdentifier implements FoodIdentifier {

    private static final int DEFAULT_LIMIT = 8;

    private final FoodNutritionCache cache;

    public CatalogFoodIdentifier(FoodNutritionCache cache) {
        this.cache = cache;
    }

    @Override
    public String mode() {
        return "catalog";
    }

    @Override
    public List<FoodCandidate> identify(MultipartFile image, String hint) {
        if (hint == null || hint.trim().length() < 2) {
            return List.of();
        }
        return cache.rankMatch(hint.trim(), DEFAULT_LIMIT).stream()
                .map(r -> new FoodCandidate(r.name(), r.score(), r.category()))
                .toList();
    }
}
