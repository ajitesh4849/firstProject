package com.foodscan.backend.identify;

import com.foodscan.backend.client.AiServiceClient;
import com.foodscan.backend.dto.AiPredictResponse;
import com.foodscan.backend.nutrition.FoodNutritionCache;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Vision AI identification. Returns AI top guess plus closely related catalog matches when possible.
 */
@Component
@ConditionalOnProperty(name = "foodscan.food-identifier", havingValue = "ai")
public class AiFoodIdentifier implements FoodIdentifier {

    private final AiServiceClient aiServiceClient;
    private final FoodNutritionCache cache;

    public AiFoodIdentifier(AiServiceClient aiServiceClient, FoodNutritionCache cache) {
        this.aiServiceClient = aiServiceClient;
        this.cache = cache;
    }

    @Override
    public String mode() {
        return "ai";
    }

    @Override
    public List<FoodCandidate> identify(MultipartFile image, String hint) {
        AiPredictResponse prediction = aiServiceClient.predict(image);
        String name = prediction.foodName() == null ? "" : prediction.foodName().trim();
        double confidence = prediction.confidence();

        Map<String, FoodCandidate> byName = new LinkedHashMap<>();
        if (!name.isBlank()) {
            String category = cache.findEntry(name).map(FoodNutritionCache.FoodCatalogEntry::category).orElse("GENERAL");
            byName.put(name.toLowerCase(Locale.ENGLISH), new FoodCandidate(name, confidence, category));
            for (FoodNutritionCache.RankedMatch related : cache.rankMatch(name, 5)) {
                byName.putIfAbsent(
                        related.name().toLowerCase(Locale.ENGLISH),
                        new FoodCandidate(related.name(), related.score() * confidence, related.category())
                );
            }
        }

        if (hint != null && hint.trim().length() >= 2) {
            for (FoodNutritionCache.RankedMatch related : cache.rankMatch(hint.trim(), 5)) {
                byName.putIfAbsent(
                        related.name().toLowerCase(Locale.ENGLISH),
                        new FoodCandidate(related.name(), related.score(), related.category())
                );
            }
        }

        List<FoodCandidate> out = new ArrayList<>(byName.values());
        out.sort((a, b) -> Double.compare(b.confidence(), a.confidence()));
        if (out.size() > 8) {
            return List.copyOf(out.subList(0, 8));
        }
        return List.copyOf(out);
    }
}
