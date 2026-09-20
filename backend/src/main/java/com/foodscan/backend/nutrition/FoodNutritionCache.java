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
        return rankMatch(query, max).stream()
                .map(r -> new FoodCatalogEntry(r.name(), r.normalizedName(), r.category(), r.profile()))
                .toList();
    }

    /**
     * Rank catalog foods by real string similarity to {@code query}.
     * Score is in {@code [0, 1]} (1 = exact normalized match).
     */
    public List<RankedMatch> rankMatch(String query, int limit) {
        int max = Math.max(1, Math.min(limit, 30));
        if (query == null || query.isBlank()) {
            return List.of();
        }
        String q = query.trim().toLowerCase(Locale.ENGLISH);
        String[] qTokens = tokenize(q);
        List<RankedMatch> ranked = new ArrayList<>();
        for (FoodCatalogEntry entry : catalog) {
            double score = scoreMatch(q, qTokens, entry.normalizedName(), entry.name().toLowerCase(Locale.ENGLISH));
            if (score >= 0.35) {
                ranked.add(new RankedMatch(
                        entry.name(),
                        entry.normalizedName(),
                        entry.category(),
                        entry.profile(),
                        round2(score)
                ));
            }
        }
        ranked.sort(Comparator
                .comparingDouble(RankedMatch::score).reversed()
                .thenComparing(r -> r.name().toLowerCase(Locale.ENGLISH)));
        if (ranked.size() <= max) {
            return List.copyOf(ranked);
        }
        return List.copyOf(ranked.subList(0, max));
    }

    private static double scoreMatch(String q, String[] qTokens, String normalized, String displayLower) {
        if (normalized.equals(q) || displayLower.equals(q)) {
            return 1.0;
        }
        if (normalized.startsWith(q) || displayLower.startsWith(q)) {
            return clamp(0.92 - Math.min(0.12, (normalized.length() - q.length()) * 0.01));
        }
        if (containsWholeToken(normalized, q) || containsWholeToken(displayLower, q)) {
            return 0.88;
        }
        if (normalized.contains(q) || displayLower.contains(q)) {
            return clamp(0.72 + Math.min(0.12, q.length() * 0.01));
        }

        String[] nameTokens = tokenize(normalized);
        double jaccard = tokenJaccard(qTokens, nameTokens);
        if (jaccard >= 0.5) {
            return clamp(0.55 + jaccard * 0.35);
        }

        double bestEdit = 0;
        for (String token : nameTokens) {
            if (token.length() < 2) {
                continue;
            }
            bestEdit = Math.max(bestEdit, editSimilarity(q, token));
            for (String qt : qTokens) {
                bestEdit = Math.max(bestEdit, editSimilarity(qt, token));
            }
        }
        if (bestEdit >= 0.75) {
            return clamp(0.45 + bestEdit * 0.35);
        }
        if (jaccard > 0) {
            return clamp(0.35 + jaccard * 0.25);
        }
        return 0;
    }

    private static String[] tokenize(String value) {
        return value.split("[^a-z0-9]+");
    }

    private static boolean containsWholeToken(String haystack, String needle) {
        for (String token : tokenize(haystack)) {
            if (token.equals(needle)) {
                return true;
            }
        }
        return false;
    }

    private static double tokenJaccard(String[] a, String[] b) {
        if (a.length == 0 || b.length == 0) {
            return 0;
        }
        java.util.Set<String> left = new java.util.HashSet<>();
        java.util.Set<String> right = new java.util.HashSet<>();
        for (String t : a) {
            if (t.length() >= 2) {
                left.add(t);
            }
        }
        for (String t : b) {
            if (t.length() >= 2) {
                right.add(t);
            }
        }
        if (left.isEmpty() || right.isEmpty()) {
            return 0;
        }
        int intersection = 0;
        for (String t : left) {
            if (right.contains(t)) {
                intersection++;
            }
        }
        int union = left.size() + right.size() - intersection;
        return union == 0 ? 0 : (double) intersection / union;
    }

    private static double editSimilarity(String a, String b) {
        if (a.equals(b)) {
            return 1.0;
        }
        int max = Math.max(a.length(), b.length());
        if (max == 0) {
            return 1.0;
        }
        int dist = levenshtein(a, b);
        return 1.0 - ((double) dist / max);
    }

    private static int levenshtein(String a, String b) {
        int[] prev = new int[b.length() + 1];
        int[] curr = new int[b.length() + 1];
        for (int j = 0; j <= b.length(); j++) {
            prev[j] = j;
        }
        for (int i = 1; i <= a.length(); i++) {
            curr[0] = i;
            char ca = a.charAt(i - 1);
            for (int j = 1; j <= b.length(); j++) {
                int cost = ca == b.charAt(j - 1) ? 0 : 1;
                curr[j] = Math.min(Math.min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
            }
            int[] tmp = prev;
            prev = curr;
            curr = tmp;
        }
        return prev[b.length()];
    }

    private static double clamp(double value) {
        return Math.max(0, Math.min(1, value));
    }

    private static double round2(double value) {
        return Math.round(value * 100.0) / 100.0;
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

    public record RankedMatch(
            String name,
            String normalizedName,
            String category,
            MacroProfile profile,
            double score
    ) {
    }
}
