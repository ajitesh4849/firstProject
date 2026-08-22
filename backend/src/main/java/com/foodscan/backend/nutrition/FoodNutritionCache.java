package com.foodscan.backend.nutrition;

import com.foodscan.backend.entity.FoodNutrition;
import com.foodscan.backend.repository.FoodNutritionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

/**
 * In-memory index of {@link FoodNutrition} rows.
 * Reloaded once at startup (and on demand) — estimate path never hits Postgres.
 */
@Component
public class FoodNutritionCache {

    private static final Logger log = LoggerFactory.getLogger(FoodNutritionCache.class);

    private final FoodNutritionRepository repository;

    /** Immutable snapshot swapped atomically on reload. */
    private volatile Map<String, MacroProfile> byKey = Map.of();

    public FoodNutritionCache(FoodNutritionRepository repository) {
        this.repository = repository;
    }

    public void reload() {
        List<FoodNutrition> rows = repository.findAll();
        Map<String, MacroProfile> next = new HashMap<>(Math.max(16, rows.size() * 2));
        for (FoodNutrition row : rows) {
            MacroProfile profile = toProfile(row);
            put(next, row.getNormalizedName(), profile);
            for (String alias : row.aliasList()) {
                put(next, alias, profile);
            }
        }
        byKey = Map.copyOf(next);
        log.info("Food nutrition cache loaded: {} foods, {} keys", rows.size(), byKey.size());
    }

    public int size() {
        return byKey.size();
    }

    public Optional<MacroProfile> find(String foodName) {
        if (foodName == null || foodName.isBlank()) {
            return Optional.empty();
        }
        String normalized = foodName.trim().toLowerCase(Locale.ENGLISH);
        MacroProfile exact = byKey.get(normalized);
        if (exact != null) {
            return Optional.of(exact);
        }

        // Short contains match over in-memory keys only (typically < few hundred).
        MacroProfile best = null;
        int bestLen = 0;
        for (Map.Entry<String, MacroProfile> entry : byKey.entrySet()) {
            String key = entry.getKey();
            if (key.length() < 3) {
                continue;
            }
            if (normalized.contains(key) || key.contains(normalized)) {
                if (key.length() > bestLen) {
                    best = entry.getValue();
                    bestLen = key.length();
                }
            }
        }
        return Optional.ofNullable(best);
    }

    private static void put(Map<String, MacroProfile> map, String key, MacroProfile profile) {
        if (key == null || key.isBlank()) {
            return;
        }
        map.putIfAbsent(key.trim().toLowerCase(Locale.ENGLISH), profile);
    }

    private static MacroProfile toProfile(FoodNutrition row) {
        return new MacroProfile(
                row.getCaloriesPer100g(),
                nz(row.getProteinPer100g()),
                nz(row.getCarbsPer100g()),
                nz(row.getFatPer100g()),
                nz(row.getFibrePer100g()),
                nz(row.getSugarPer100g()),
                nz(row.getSodiumMgPer100g())
        );
    }

    private static double nz(Double value) {
        return value == null ? 0.0 : value;
    }
}
