package com.foodscan.backend.packaged;

import com.foodscan.backend.dto.PackagedRiskFlagDto;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Rule-based packaged food risk checks (no AI).
 * Educational only — not a lab analysis or medical advice.
 */
@Component
public class PackagedFoodRiskAnalyzer {

    public static final String DISCLAIMER =
            "Based on packaged product data and ingredient rules — not a lab test or medical advice.";

    private static final Pattern E_NUMBER = Pattern.compile("\\be\\s?(\\d{3}[a-z]?)\\b", Pattern.CASE_INSENSITIVE);

    private static final Map<String, String> COLOR_CODES = Map.ofEntries(
            Map.entry("102", "Tartrazine (yellow artificial color)"),
            Map.entry("104", "Quinoline Yellow"),
            Map.entry("110", "Sunset Yellow"),
            Map.entry("122", "Carmoisine / Azorubine"),
            Map.entry("124", "Ponceau 4R (red artificial color)"),
            Map.entry("129", "Allura Red"),
            Map.entry("133", "Brilliant Blue"),
            Map.entry("150d", "Sulphite ammonia caramel color")
    );

    private static final Map<String, String> PRESERVATIVE_CODES = Map.ofEntries(
            Map.entry("211", "Sodium benzoate (preservative)"),
            Map.entry("202", "Potassium sorbate (preservative)"),
            Map.entry("221", "Sodium sulphite (preservative)"),
            Map.entry("250", "Sodium nitrite (preservative)"),
            Map.entry("251", "Sodium nitrate (preservative)")
    );

    public AnalysisResult analyze(OpenFoodFactsProduct product) {
        List<PackagedRiskFlagDto> flags = new ArrayList<>();
        String ingredients = safe(product.ingredientsText()).toLowerCase(Locale.ENGLISH);
        String categories = safe(product.categories()).toLowerCase(Locale.ENGLISH);
        String name = safe(product.productName()).toLowerCase(Locale.ENGLISH);

        detectENumbers(ingredients, flags);
        detectKeywordRisks(ingredients, flags);
        detectNutritionRisks(product, flags);

        String score = scoreFor(flags);
        List<String> swaps = healthierSwaps(name, categories, flags);

        return new AnalysisResult(score, flags, swaps, DISCLAIMER);
    }

    private void detectENumbers(String ingredients, List<PackagedRiskFlagDto> flags) {
        Matcher matcher = E_NUMBER.matcher(ingredients);
        Map<String, PackagedRiskFlagDto> unique = new LinkedHashMap<>();
        while (matcher.find()) {
            String code = matcher.group(1).toLowerCase(Locale.ENGLISH);
            if (COLOR_CODES.containsKey(code)) {
                unique.putIfAbsent("color-" + code, new PackagedRiskFlagDto(
                        "E" + code.toUpperCase(Locale.ENGLISH),
                        "Artificial color",
                        "high",
                        COLOR_CODES.get(code)
                ));
            } else if (PRESERVATIVE_CODES.containsKey(code)) {
                unique.putIfAbsent("pres-" + code, new PackagedRiskFlagDto(
                        "E" + code.toUpperCase(Locale.ENGLISH),
                        "Preservative",
                        "medium",
                        PRESERVATIVE_CODES.get(code)
                ));
            }
        }
        flags.addAll(unique.values());
    }

    private void detectKeywordRisks(String ingredients, List<PackagedRiskFlagDto> flags) {
        if (textContainsAny(ingredients, "hydrogenated", "partially hydrogenated", "trans fat", "vanaspati")) {
            flags.add(new PackagedRiskFlagDto(
                    "TRANS_FAT",
                    "Hydrogenated / trans fat risk",
                    "high",
                    "Label mentions hydrogenated fat or trans fat, which is best limited."
            ));
        }
        if (textContainsAny(ingredients, "monosodium glutamate", "msg", "e621")) {
            flags.add(new PackagedRiskFlagDto(
                    "MSG",
                    "Flavor enhancer (MSG)",
                    "medium",
                    "MSG / E621 is common in savory snacks and instant foods."
            ));
        }
        if (textContainsAny(ingredients, "high fructose corn syrup", "glucose-fructose", "invert sugar")) {
            flags.add(new PackagedRiskFlagDto(
                    "ADDED_SUGARS",
                    "Added refined sugars",
                    "medium",
                    "Contains concentrated added sugars beyond basic sucrose."
            ));
        }
        if (textContainsAny(ingredients, "aspartame", "sucralose", "acesulfame", "saccharin")) {
            flags.add(new PackagedRiskFlagDto(
                    "ARTIFICIAL_SWEETENER",
                    "Artificial sweetener",
                    "low",
                    "Contains non-nutritive artificial sweeteners."
            ));
        }
        if (textContainsAny(ingredients, "palm oil") && textContainsAny(ingredients, "sugar", "glucose", "fructose")) {
            flags.add(new PackagedRiskFlagDto(
                    "UPF_SIGNAL",
                    "Ultra-processed signals",
                    "medium",
                    "Combination of refined oils and sugars is common in ultra-processed snacks."
            ));
        }
    }

    private void detectNutritionRisks(OpenFoodFactsProduct product, List<PackagedRiskFlagDto> flags) {
        Double sugar = product.sugarPer100g();
        if (sugar != null && sugar >= 22.5) {
            flags.add(new PackagedRiskFlagDto(
                    "HIGH_SUGAR",
                    "High sugar",
                    "high",
                    String.format(Locale.ENGLISH, "%.1fg sugar per 100g (high threshold ≥ 22.5g).", sugar)
            ));
        } else if (sugar != null && sugar >= 12.5) {
            flags.add(new PackagedRiskFlagDto(
                    "MED_SUGAR",
                    "Moderate-to-high sugar",
                    "medium",
                    String.format(Locale.ENGLISH, "%.1fg sugar per 100g.", sugar)
            ));
        }

        Double salt = product.saltPer100g();
        if (salt != null && salt >= 1.5) {
            flags.add(new PackagedRiskFlagDto(
                    "HIGH_SALT",
                    "High salt",
                    "high",
                    String.format(Locale.ENGLISH, "%.2fg salt per 100g (high threshold ≥ 1.5g).", salt)
            ));
        } else if (salt != null && salt >= 0.9) {
            flags.add(new PackagedRiskFlagDto(
                    "MED_SALT",
                    "Moderate-to-high salt",
                    "medium",
                    String.format(Locale.ENGLISH, "%.2fg salt per 100g.", salt)
            ));
        }
    }

    private String scoreFor(List<PackagedRiskFlagDto> flags) {
        long high = flags.stream().filter(f -> "high".equalsIgnoreCase(f.severity())).count();
        long medium = flags.stream().filter(f -> "medium".equalsIgnoreCase(f.severity())).count();
        if (high >= 2 || (high >= 1 && medium >= 2)) {
            return "CAUTION";
        }
        if (high >= 1 || medium >= 2) {
            return "OK";
        }
        if (medium >= 1 || !flags.isEmpty()) {
            return "OK";
        }
        return "BETTER";
    }

    private List<String> healthierSwaps(String name, String categories, List<PackagedRiskFlagDto> flags) {
        List<String> swaps = new ArrayList<>();
        if (nameOrCategoryContains(name, categories, "chip", "crisp", "namkeen", "bhujia", "snack")) {
            swaps.add("Choose roasted chana, air-popped popcorn, or baked chips with shorter ingredient lists.");
            swaps.add("Prefer plain nuts/seeds without artificial colors or flavor enhancers.");
        } else if (nameOrCategoryContains(name, categories, "cola", "soda", "soft drink", "beverage", "juice drink")) {
            swaps.add("Swap sugary drinks for water, sparkling water, or unsweetened buttermilk.");
            swaps.add("If you want flavor, try fresh lime water with less sugar.");
        } else if (nameOrCategoryContains(name, categories, "noodle", "ramen", "instant")) {
            swaps.add("Prefer whole-grain noodles or homemade stir-fry with vegetables.");
            swaps.add("If using instant packs, discard flavor sachet or use half to cut salt.");
        } else if (nameOrCategoryContains(name, categories, "biscuit", "cookie", "chocolate", "candy", "sweet")) {
            swaps.add("Choose dark chocolate (higher cocoa) in small portions, or fruit + nuts.");
            swaps.add("Look for biscuits with less sugar and no artificial colors.");
        } else if (nameOrCategoryContains(name, categories, "cereal", "breakfast")) {
            swaps.add("Pick unsweetened oats or muesli and add fruit yourself.");
        } else {
            swaps.add("Compare labels: fewer additives and lower sugar/salt per 100g is usually better.");
            swaps.add("Prefer products with recognizable whole-food ingredients near the top of the list.");
        }

        boolean hasColor = flags.stream().anyMatch(f -> f.title().toLowerCase(Locale.ENGLISH).contains("color"));
        if (hasColor) {
            swaps.add("Avoid brightly colored packaged snacks when a naturally colored alternative exists.");
        }
        return swaps.stream().distinct().limit(4).toList();
    }

    private static boolean textContainsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private static boolean nameOrCategoryContains(String name, String categories, String... keywords) {
        return textContainsAny(name + " " + categories, keywords);
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    public record AnalysisResult(
            String score,
            List<PackagedRiskFlagDto> flags,
            List<String> healthierSwaps,
            String disclaimer
    ) {
    }
}
