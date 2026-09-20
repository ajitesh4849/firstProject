package com.foodscan.backend.nutrition;

import com.foodscan.backend.entity.FoodNutrition;
import com.foodscan.backend.repository.FoodNutritionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

/**
 * In-memory index of {@link FoodNutrition} rows.
 * Reloaded once at startup — estimate/search never hit Postgres on the request path.
 */
@Component
public class FoodNutritionCache {

    private static final Logger log = LoggerFactory.getLogger(FoodNutritionCache.class);

    private final FoodNutritionRepository repository;

    private volatile Map<String, MacroProfile> byKey = Map.of();
    private volatile List<FoodCatalogEntry> catalog = List.of();

    public FoodNutritionCache(FoodNutritionRepository repository) {
        this.repository = repository;
    }

    public void reload() {
        List<FoodNutrition> rows = repository.findAll();
        Map<String, MacroProfile> next = new HashMap<>(Math.max(16, rows.size() * 2));
        List<FoodCatalogEntry> entries = new ArrayList<>(rows.size());
        for (FoodNutrition row : rows) {
            MacroProfile profile = toProfile(row);
            put(next, row.getNormalizedName(), profile);
            for (String alias : row.aliasList()) {
                put(next, alias, profile);
            }
            entries.add(new FoodCatalogEntry(
                    row.getName(),
                    row.getNormalizedName(),
                    row.getCategory() == null ? "GENERAL" : row.getCategory(),
                    profile
            ));
        }
        entries.sort(Comparator.comparing(e -> e.name().toLowerCase(Locale.ENGLISH)));
        byKey = Map.copyOf(next);
        catalog = List.copyOf(entries);
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

    public Optional<FoodCatalogEntry> findEntry(String foodName) {
        if (foodName == null || foodName.isBlank()) {
            return Optional.empty();
        }
        String normalized = foodName.trim().toLowerCase(Locale.ENGLISH);
        for (FoodCatalogEntry entry : catalog) {
            if (entry.normalizedName().equals(normalized)) {
                return Optional.of(entry);
            }
        }
        return find(foodName).flatMap(profile -> catalog.stream()
                .filter(e -> e.profile().equals(profile))
                .findFirst());
    }

    /** In-memory search — typically &lt;1ms for curated catalog sizes. */
    public List<FoodCatalogEntry> search(String query, int limit) {
        int max = Math.max(1, Math.min(limit, 30));
        if (query == null || query.isBlank()) {
            return catalog.stream().limit(max).toList();
        }
        String q = query.trim().toLowerCase(Locale.ENGLISH);
        List<FoodCatalogEntry> hits = new ArrayList<>();
        for (FoodCatalogEntry entry : catalog) {
            if (entry.normalizedName().contains(q)
                    || entry.name().toLowerCase(Locale.ENGLISH).contains(q)
                    || entry.category().toLowerCase(Locale.ENGLISH).contains(q)) {
                hits.add(entry);
                if (hits.size() >= max) {
                    break;
                }
            }
        }
        return hits;
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

    public record FoodCatalogEntry(
            String name,
            String normalizedName,
            String category,
            MacroProfile profile
    ) {
    }
}
