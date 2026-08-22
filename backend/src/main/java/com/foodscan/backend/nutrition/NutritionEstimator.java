package com.foodscan.backend.nutrition;

import org.springframework.stereotype.Component;

import java.util.Locale;

/**
 * Resolves meal nutrition estimates from the in-memory {@link FoodNutritionCache}
 * (backed by Postgres seeds). Falls back to lightweight keyword heuristics only
 * when the cache has no match — never queries the database on the request path.
 */
@Component
public class NutritionEstimator {

    private static final MacroProfile DEFAULT = new MacroProfile(180, 8.0, 18.0, 8.0, 2.5, 3.0, 220);

    private final FoodNutritionCache cache;

    public NutritionEstimator(FoodNutritionCache cache) {
        this.cache = cache;
    }

    /** Offline / unit-test constructor — heuristics only, no DB. */
    public NutritionEstimator() {
        this.cache = null;
    }

    public MacroProfile estimateFor(String foodName) {
        if (foodName == null || foodName.isBlank()) {
            return DEFAULT;
        }

        if (cache != null) {
            var cached = cache.find(foodName);
            if (cached.isPresent()) {
                return cached.get();
            }
        }

        return estimateByKeywords(foodName.trim().toLowerCase(Locale.ENGLISH));
    }

    private MacroProfile estimateByKeywords(String name) {
        if (containsAny(name, "salad", "greens", "spinach")) {
            return new MacroProfile(55, 2.5, 7.0, 2.0, 2.5, 2.5, 90);
        }
        if (containsAny(name, "pizza")) {
            return new MacroProfile(255, 11.0, 30.0, 10.0, 2.0, 3.5, 520);
        }
        if (containsAny(name, "dosa", "uttapam")) {
            return new MacroProfile(170, 4.0, 28.0, 5.0, 2.5, 1.5, 350);
        }
        if (containsAny(name, "biryani", "pulao", "fried rice")) {
            return new MacroProfile(185, 8.0, 25.0, 6.0, 1.5, 1.0, 380);
        }
        if (containsAny(name, "paneer", "cheese")) {
            return new MacroProfile(220, 12.0, 8.0, 16.0, 1.0, 3.0, 350);
        }
        if (containsAny(name, "chicken", "turkey")) {
            return new MacroProfile(180, 22.0, 4.0, 8.0, 0.5, 1.0, 300);
        }
        if (containsAny(name, "fish", "salmon", "tuna")) {
            return new MacroProfile(160, 22.0, 0.5, 7.0, 0.0, 0.0, 280);
        }
        if (containsAny(name, "dal", "lentil", "beans", "rajma", "chole")) {
            return new MacroProfile(130, 8.0, 18.0, 3.0, 5.0, 1.5, 320);
        }
        if (containsAny(name, "rice", "khichdi")) {
            return new MacroProfile(135, 3.0, 28.0, 1.0, 1.0, 0.5, 80);
        }
        if (containsAny(name, "burger", "sandwich")) {
            return new MacroProfile(260, 13.0, 26.0, 12.0, 2.0, 4.0, 480);
        }
        if (containsAny(name, "fries", "fried", "pakora", "samosa")) {
            return new MacroProfile(290, 5.0, 30.0, 16.0, 2.0, 1.5, 400);
        }
        if (containsAny(name, "fruit", "apple", "banana", "mango")) {
            return new MacroProfile(70, 0.8, 17.0, 0.3, 2.5, 12.0, 5);
        }
        if (containsAny(name, "sweet", "dessert", "cake", "ice cream", "halwa", "gulab", "jalebi")) {
            return new MacroProfile(280, 4.0, 40.0, 12.0, 1.0, 28.0, 120);
        }
        if (containsAny(name, "roti", "chapati", "phulka")) {
            return new MacroProfile(300, 10.0, 50.0, 7.0, 6.5, 1.5, 220);
        }
        if (containsAny(name, "idli")) {
            return new MacroProfile(120, 4.0, 22.0, 1.0, 1.5, 0.5, 280);
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
