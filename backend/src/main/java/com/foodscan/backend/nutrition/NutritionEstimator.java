package com.foodscan.backend.nutrition;

import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Rough food-name based nutrition estimates (per 100g).
 * Not a certified nutrition database — values are approximate for MVP tracking.
 */
@Component
public class NutritionEstimator {

    private static final MacroProfile DEFAULT = new MacroProfile(180, 8.0, 18.0, 8.0);

    private final Map<String, MacroProfile> exactMatches = new LinkedHashMap<>();

    public NutritionEstimator() {
        // Matches mock AI / common Indian + global dishes
        exactMatches.put("paneer butter masala", new MacroProfile(220, 10.0, 10.0, 16.0));
        exactMatches.put("butter chicken", new MacroProfile(210, 14.0, 8.0, 14.0));
        exactMatches.put("masala dosa", new MacroProfile(170, 4.0, 28.0, 5.0));
        exactMatches.put("garden salad", new MacroProfile(45, 2.0, 6.0, 1.5));
        exactMatches.put("margherita pizza", new MacroProfile(250, 11.0, 30.0, 9.0));
        exactMatches.put("chicken biryani", new MacroProfile(190, 10.0, 24.0, 6.0));
        exactMatches.put("dal tadka", new MacroProfile(130, 7.0, 16.0, 4.0));
        exactMatches.put("idli", new MacroProfile(120, 4.0, 22.0, 1.0));
        exactMatches.put("samosa", new MacroProfile(260, 5.0, 28.0, 14.0));
        exactMatches.put("french fries", new MacroProfile(310, 3.5, 40.0, 15.0));
        exactMatches.put("hamburger", new MacroProfile(265, 13.0, 24.0, 14.0));
        exactMatches.put("caesar salad", new MacroProfile(120, 7.0, 6.0, 8.0));
        exactMatches.put("grilled chicken", new MacroProfile(165, 31.0, 0.0, 3.5));
        exactMatches.put("white rice", new MacroProfile(130, 2.5, 28.0, 0.3));
        exactMatches.put("chapati", new MacroProfile(300, 10.0, 50.0, 7.0));
        exactMatches.put("unknown food", DEFAULT);
    }

    public MacroProfile estimateFor(String foodName) {
        if (foodName == null || foodName.isBlank()) {
            return DEFAULT;
        }

        String normalized = foodName.trim().toLowerCase(Locale.ENGLISH);
        MacroProfile exact = exactMatches.get(normalized);
        if (exact != null) {
            return exact;
        }

        for (Map.Entry<String, MacroProfile> entry : exactMatches.entrySet()) {
            if (normalized.contains(entry.getKey()) || entry.getKey().contains(normalized)) {
                return entry.getValue();
            }
        }

        return estimateByKeywords(normalized);
    }

    private MacroProfile estimateByKeywords(String name) {
        if (containsAny(name, "salad", "greens", "spinach")) {
            return new MacroProfile(55, 2.5, 7.0, 2.0);
        }
        if (containsAny(name, "pizza")) {
            return new MacroProfile(255, 11.0, 30.0, 10.0);
        }
        if (containsAny(name, "dosa", "uttapam")) {
            return new MacroProfile(170, 4.0, 28.0, 5.0);
        }
        if (containsAny(name, "biryani", "pulao", "fried rice")) {
            return new MacroProfile(185, 8.0, 25.0, 6.0);
        }
        if (containsAny(name, "paneer", "cheese")) {
            return new MacroProfile(220, 12.0, 8.0, 16.0);
        }
        if (containsAny(name, "chicken", "turkey")) {
            return new MacroProfile(180, 22.0, 4.0, 8.0);
        }
        if (containsAny(name, "fish", "salmon", "tuna")) {
            return new MacroProfile(160, 22.0, 0.5, 7.0);
        }
        if (containsAny(name, "dal", "lentil", "beans")) {
            return new MacroProfile(130, 8.0, 18.0, 3.0);
        }
        if (containsAny(name, "rice", "khichdi")) {
            return new MacroProfile(135, 3.0, 28.0, 1.0);
        }
        if (containsAny(name, "burger", "sandwich")) {
            return new MacroProfile(260, 13.0, 26.0, 12.0);
        }
        if (containsAny(name, "fries", "fried", "pakora", "samosa")) {
            return new MacroProfile(290, 5.0, 30.0, 16.0);
        }
        if (containsAny(name, "fruit", "apple", "banana", "mango")) {
            return new MacroProfile(70, 0.8, 17.0, 0.3);
        }
        if (containsAny(name, "sweet", "dessert", "cake", "ice cream", "halwa")) {
            return new MacroProfile(280, 4.0, 40.0, 12.0);
        }
        return DEFAULT;
    }

    private static boolean containsAny(String name, String... keywords) {
        for (String keyword : keywords) {
            if (name.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
