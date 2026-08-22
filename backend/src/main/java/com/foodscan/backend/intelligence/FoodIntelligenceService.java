package com.foodscan.backend.intelligence;

import com.foodscan.backend.dto.AlternativeDto;
import com.foodscan.backend.dto.AnalysisPointDto;
import com.foodscan.backend.dto.FoodIntelligenceDto;
import com.foodscan.backend.dto.PackagedIngredientMarkDto;
import com.foodscan.backend.dto.PackagedRiskFlagDto;
import com.foodscan.backend.packaged.OpenFoodFactsProduct;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Rule-based food intelligence: score, GOOD/WATCH with why, personalized verdict, alternatives.
 * Educational estimates — not medical advice.
 */
@Component
public class FoodIntelligenceService {

    public FoodIntelligenceDto forMeal(
            String foodName,
            int calories,
            double proteinGrams,
            double carbsGrams,
            double fatGrams,
            double fibreGrams,
            double sugarGrams,
            double sodiumMg,
            int portionGrams,
            String userGoal
    ) {
        String goal = normalizeGoal(userGoal);
        List<AnalysisPointDto> good = new ArrayList<>();
        List<AnalysisPointDto> watch = new ArrayList<>();

        double proteinPer100kcal = calories > 0 ? (proteinGrams * 100.0) / calories : 0;
        double fibrePer100g = portionGrams > 0 ? (fibreGrams * 100.0) / portionGrams : fibreGrams;
        double sugarPer100g = portionGrams > 0 ? (sugarGrams * 100.0) / portionGrams : sugarGrams;
        double fatShare = calories > 0 ? (fatGrams * 9.0 * 100.0) / calories : 0;

        if (proteinPer100kcal >= 6) {
            good.add(point(
                    "GOOD",
                    "Good protein",
                    String.format(Locale.ENGLISH, "%.0fg protein (~%.1fg per 100 kcal).", proteinGrams, proteinPer100kcal)
            ));
        } else if (proteinGrams >= 15) {
            good.add(point(
                    "GOOD",
                    "Solid protein portion",
                    String.format(Locale.ENGLISH, "%.0fg protein in this serving.", proteinGrams)
            ));
        }

        if (fibreGrams >= 5 || fibrePer100g >= 6) {
            good.add(point(
                    "GOOD",
                    "Good fibre",
                    String.format(Locale.ENGLISH, "%.1fg fibre — helpful for fullness and digestion.", fibreGrams)
            ));
        }

        if (sugarPer100g < 5 && sugarGrams < 8) {
            good.add(point(
                    "GOOD",
                    "Low added-sugar pattern",
                    String.format(Locale.ENGLISH, "Estimated ~%.1fg sugar in this portion.", sugarGrams)
            ));
        }

        if (calories >= 550) {
            watch.add(point(
                    "WATCH",
                    "High calories for one item",
                    String.format(Locale.ENGLISH, "%d kcal in %dg — portion size drives most of the impact.", calories, portionGrams)
            ));
        }
        if (fatShare >= 40) {
            watch.add(point(
                    "WATCH",
                    "High fat share",
                    String.format(Locale.ENGLISH, "Fat provides ~%.0f%% of calories in this estimate.", fatShare)
            ));
        }
        if (sugarPer100g >= 12.5 || sugarGrams >= 20) {
            watch.add(point(
                    "WATCH",
                    "High sugar",
                    String.format(Locale.ENGLISH, "Estimated ~%.1fg sugar — prefer less frequent or smaller portions.", sugarGrams)
            ));
        }
        if (sodiumMg >= 600) {
            watch.add(point(
                    "WATCH",
                    "High sodium",
                    String.format(Locale.ENGLISH, "Estimated ~%.0fmg sodium — watch total salt for the day.", sodiumMg)
            ));
        }
        if (carbsGrams >= 70 && proteinGrams < 12) {
            watch.add(point(
                    "WATCH",
                    "Carb-heavy, lower protein",
                    String.format(Locale.ENGLISH, "%.0fg carbs with only %.0fg protein — pairing with dal/curd/eggs can balance it.", carbsGrams, proteinGrams)
            ));
        }

        if (good.isEmpty() && watch.isEmpty()) {
            good.add(point(
                    "GOOD",
                    "Moderate profile",
                    "No extreme sugar, sodium, or calorie flags for this estimate."
            ));
        }

        int base = 72;
        base += Math.min(12, (int) Math.round(proteinPer100kcal));
        base += fibreGrams >= 5 ? 6 : (fibreGrams >= 3 ? 3 : 0);
        base -= calories >= 700 ? 12 : (calories >= 550 ? 7 : 0);
        base -= fatShare >= 45 ? 8 : (fatShare >= 35 ? 4 : 0);
        base -= sugarPer100g >= 22.5 ? 12 : (sugarPer100g >= 12.5 ? 6 : 0);
        base -= sodiumMg >= 800 ? 10 : (sodiumMg >= 600 ? 5 : 0);
        int healthScore = clamp(base);
        String band = bandFor(healthScore);

        int personalizedScore = personalizeScore(healthScore, goal, calories, proteinGrams, fatGrams, sugarGrams, fibreGrams);
        String verdict = mealVerdict(goal, personalizedScore, healthScore, calories, proteinGrams, portionGrams);
        List<AlternativeDto> alternatives = mealAlternatives(foodName, goal, watch);

        return new FoodIntelligenceDto(
                healthScore,
                band,
                good,
                watch,
                personalizedScore,
                verdict,
                goal,
                alternatives
        );
    }

    public FoodIntelligenceDto forPackaged(
            OpenFoodFactsProduct product,
            List<PackagedRiskFlagDto> flags,
            List<PackagedIngredientMarkDto> marks,
            String userGoal
    ) {
        String goal = normalizeGoal(userGoal);
        List<AnalysisPointDto> good = new ArrayList<>();
        List<AnalysisPointDto> watch = new ArrayList<>();

        long healthierMarks = marks == null ? 0 : marks.stream().filter(m -> "HEALTHIER".equalsIgnoreCase(m.tag())).count();
        if (healthierMarks > 0) {
            good.add(point(
                    "GOOD",
                    "Preferable ingredients spotted",
                    healthierMarks + " ingredient mark(s) lean toward whole-food or less-processed choices."
            ));
        }

        Double sugar = product.sugarPer100g();
        Double salt = product.saltPer100g();
        Double energy = product.energyKcalPer100g();
        Double protein = product.proteinPer100g();
        Double fibre = product.fibrePer100g();

        if (protein != null && protein >= 8) {
            good.add(point(
                    "GOOD",
                    "Decent protein density",
                    String.format(Locale.ENGLISH, "%.1fg protein per 100g.", protein)
            ));
        }
        if (fibre != null && fibre >= 6) {
            good.add(point(
                    "GOOD",
                    "Good fibre",
                    String.format(Locale.ENGLISH, "%.1fg fibre per 100g.", fibre)
            ));
        }
        if (sugar != null && sugar < 5) {
            good.add(point(
                    "GOOD",
                    "Low sugar (per 100g)",
                    String.format(Locale.ENGLISH, "%.1fg sugar per 100g.", sugar)
            ));
        }

        if (flags != null) {
            for (PackagedRiskFlagDto flag : flags) {
                watch.add(point("WATCH", flag.title(), flag.detail()));
            }
        }

        if (good.isEmpty() && (watch.isEmpty())) {
            good.add(point(
                    "GOOD",
                    "No major rule flags",
                    "Based on available label data and ingredient rules — still compare servings."
            ));
        }

        int score = 82;
        if (flags != null) {
            for (PackagedRiskFlagDto flag : flags) {
                if ("high".equalsIgnoreCase(flag.severity())) {
                    score -= 14;
                } else if ("medium".equalsIgnoreCase(flag.severity())) {
                    score -= 7;
                } else {
                    score -= 3;
                }
            }
        }
        score += (int) Math.min(8, healthierMarks * 3);
        if (sugar != null && sugar >= 22.5) {
            score -= 6;
        }
        if (salt != null && salt >= 1.5) {
            score -= 6;
        }
        if (fibre != null && fibre >= 6) {
            score += 4;
        }
        if (protein != null && protein >= 10) {
            score += 3;
        }
        int healthScore = clamp(score);
        String band = bandFor(healthScore);

        double estFat = product.fatPer100g() == null ? 0 : product.fatPer100g();
        double estProtein = protein == null ? 0 : protein;
        double estSugar = sugar == null ? 0 : sugar;
        double estFibre = fibre == null ? 0 : fibre;
        int estCalories = energy == null ? 0 : (int) Math.round(energy);

        int personalizedScore = personalizeScore(
                healthScore,
                goal,
                estCalories,
                estProtein,
                estFat,
                estSugar,
                estFibre
        );
        String verdict = packagedVerdict(goal, personalizedScore, healthScore, sugar, salt, estProtein);
        List<AlternativeDto> alternatives = packagedAlternatives(product, flags);

        return new FoodIntelligenceDto(
                healthScore,
                band,
                limit(good, 5),
                limit(watch, 6),
                personalizedScore,
                verdict,
                goal,
                alternatives
        );
    }

    public static String legacyPackagedScore(int healthScore) {
        if (healthScore >= 75) {
            return "BETTER";
        }
        if (healthScore >= 50) {
            return "OK";
        }
        return "CAUTION";
    }

    public static String bandFor(int score) {
        if (score >= 90) {
            return "EXCELLENT";
        }
        if (score >= 75) {
            return "GOOD";
        }
        if (score >= 60) {
            return "MODERATE";
        }
        if (score >= 40) {
            return "OCCASIONAL";
        }
        return "POOR";
    }

    private int personalizeScore(
            int healthScore,
            String goal,
            int calories,
            double protein,
            double fat,
            double sugar,
            double fibre
    ) {
        int score = healthScore;
        switch (goal) {
            case "LOSE_WEIGHT" -> {
                if (calories >= 400) {
                    score -= 8;
                }
                if (sugar >= 15) {
                    score -= 6;
                }
                if (fat >= 20) {
                    score -= 4;
                }
                if (fibre >= 5) {
                    score += 4;
                }
                if (protein >= 15) {
                    score += 3;
                }
            }
            case "GAIN_MUSCLE" -> {
                if (protein >= 20) {
                    score += 8;
                } else if (protein >= 12) {
                    score += 4;
                } else {
                    score -= 6;
                }
                if (calories < 200 && protein < 10) {
                    score -= 4;
                }
            }
            default -> { // MAINTAIN
                if (protein >= 12 && fibre >= 3) {
                    score += 3;
                }
                if (sugar >= 25) {
                    score -= 5;
                }
            }
        }
        return clamp(score);
    }

    private String mealVerdict(
            String goal,
            int personalizedScore,
            int healthScore,
            int calories,
            double protein,
            int portionGrams
    ) {
        String goalLabel = goalLabel(goal);
        if (personalizedScore >= 78) {
            return "Good choice for your " + goalLabel + " goal at this portion.";
        }
        if (personalizedScore >= 60) {
            if ("LOSE_WEIGHT".equals(goal) && calories >= 450) {
                return "Fits " + goalLabel + " better if you reduce the portion (" + portionGrams + "g → smaller serving).";
            }
            if ("GAIN_MUSCLE".equals(goal) && protein < 20) {
                return "OK for " + goalLabel + ", but add a protein side (dal, eggs, curd, paneer) to improve the fit.";
            }
            return "Reasonable for " + goalLabel + ", with a few watch-outs (score " + personalizedScore + "/100 vs base " + healthScore + ").";
        }
        if ("LOSE_WEIGHT".equals(goal)) {
            return "Less ideal for " + goalLabel + " at this size — try a lighter swap or half portion.";
        }
        if ("GAIN_MUSCLE".equals(goal)) {
            return "Not the strongest pick for " + goalLabel + " — look for higher-protein alternatives below.";
        }
        return "Occasional choice for " + goalLabel + " — prefer the alternatives when you can.";
    }

    private String packagedVerdict(
            String goal,
            int personalizedScore,
            int healthScore,
            Double sugar,
            Double salt,
            double protein
    ) {
        String goalLabel = goalLabel(goal);
        if (personalizedScore >= 78) {
            return "Solid packaged pick for your " + goalLabel + " goal, based on available label data.";
        }
        if (personalizedScore >= 60) {
            if ("LOSE_WEIGHT".equals(goal) && sugar != null && sugar >= 12.5) {
                return "OK sometimes for " + goalLabel + ", but sugar per 100g is elevated — check serving size.";
            }
            if ("GAIN_MUSCLE".equals(goal) && protein < 8) {
                return "Moderate for " + goalLabel + " — protein density is low; pair with a protein-rich food.";
            }
            return "Acceptable for " + goalLabel + " with the watch items below in mind.";
        }
        if (salt != null && salt >= 1.5) {
            return "Weaker fit for " + goalLabel + " — sodium/salt looks high relative to many everyday picks.";
        }
        return "Prefer a better alternative for your " + goalLabel + " goal when shopping.";
    }

    private List<AlternativeDto> mealAlternatives(String foodName, String goal, List<AnalysisPointDto> watch) {
        String name = foodName == null ? "" : foodName.toLowerCase(Locale.ENGLISH);
        List<AlternativeDto> list = new ArrayList<>();

        if (contains(name, "biryani", "fried rice", "pulao")) {
            list.add(new AlternativeDto("Vegetable khichdi + curd", "Usually lighter, with better protein-fibre balance."));
            list.add(new AlternativeDto("Grilled chicken + salad", "Higher protein, lower refined-carb load."));
        } else if (contains(name, "pizza", "burger", "fries")) {
            list.add(new AlternativeDto("Grilled sandwich on whole-grain bread", "Lower frying oil; more controllable portions."));
            list.add(new AlternativeDto("Chicken wrap + salad", "Better protein density than most fast-food combos."));
        } else if (contains(name, "dosa", "uttapam")) {
            list.add(new AlternativeDto("Plain dosa + sambar", "Skip heavy potato fillings to cut calories."));
            list.add(new AlternativeDto("Idli + sambar", "Typically lower oil than many dosa plates."));
        } else if (contains(name, "paneer", "butter chicken", "makhani")) {
            list.add(new AlternativeDto("Tandoori / grilled paneer or chicken", "Similar protein with less creamy gravy."));
            list.add(new AlternativeDto("Dal + roti + salad", "Lower calorie density, still satisfying."));
        } else if (contains(name, "samosa", "pakora", "fried")) {
            list.add(new AlternativeDto("Roasted chana or baked snack", "Crunch with far less frying oil."));
            list.add(new AlternativeDto("Sprouts chaat", "Higher fibre and protein for the calories."));
        } else if (contains(name, "sweet", "halwa", "dessert", "ice cream")) {
            list.add(new AlternativeDto("Fruit + a few nuts", "Natural sweetness with fibre and crunch."));
            list.add(new AlternativeDto("Dark chocolate (small square)", "Portion-controlled treat with less sugar spike."));
        } else {
            list.add(new AlternativeDto("Dal + roti + vegetables", "Balanced Indian plate with protein and fibre."));
            list.add(new AlternativeDto("Curd + fruit bowl", "Lighter option that still feels like a complete snack/meal."));
        }

        if ("GAIN_MUSCLE".equals(goal)) {
            list.add(0, new AlternativeDto("Egg bhurji + roti", "Fast high-protein Indian option."));
        } else if ("LOSE_WEIGHT".equals(goal)) {
            list.add(0, new AlternativeDto("Large salad + grilled protein", "Volume eating with fewer calories."));
        }

        boolean highCalWatch = watch.stream().anyMatch(w -> w.title().toLowerCase(Locale.ENGLISH).contains("calorie"));
        if (highCalWatch) {
            list.add(new AlternativeDto("Half portion + extra vegetables", "Keeps the dish you like while cutting energy intake."));
        }

        return list.stream().distinct().limit(3).toList();
    }

    private List<AlternativeDto> packagedAlternatives(
            OpenFoodFactsProduct product,
            List<PackagedRiskFlagDto> flags
    ) {
        String name = safe(product.productName()).toLowerCase(Locale.ENGLISH);
        String categories = safe(product.categories()).toLowerCase(Locale.ENGLISH);
        String blob = name + " " + categories;
        List<AlternativeDto> list = new ArrayList<>();

        if (contains(blob, "chip", "crisp", "namkeen", "bhujia", "snack")) {
            list.add(new AlternativeDto("Roasted chana", "Crunchy, higher protein, shorter ingredient list."));
            list.add(new AlternativeDto("Air-popped popcorn", "Lower energy density than most fried chips."));
            list.add(new AlternativeDto("Plain mixed nuts (unsalted)", "More satiety per handful — watch portion."));
        } else if (contains(blob, "cola", "soda", "soft drink", "beverage", "juice drink")) {
            list.add(new AlternativeDto("Sparkling water", "Zero sugar alternative with fizz."));
            list.add(new AlternativeDto("Unsweetened buttermilk (chaas)", "More filling than sugary soft drinks."));
            list.add(new AlternativeDto("Fresh lime water (less sugar)", "Flavor with controllable sweetness."));
        } else if (contains(blob, "noodle", "ramen", "instant")) {
            list.add(new AlternativeDto("Whole-grain noodles + vegetables", "More fibre; skip or halve flavor sachet."));
            list.add(new AlternativeDto("Homemade veg stir-fry", "Lower sodium than most instant packs."));
        } else if (contains(blob, "biscuit", "cookie", "chocolate", "candy", "sweet")) {
            list.add(new AlternativeDto("Dark chocolate (high cocoa)", "Usually less sugar; keep to a small piece."));
            list.add(new AlternativeDto("Fruit + nuts", "Fibre and protein instead of refined snack biscuits."));
            list.add(new AlternativeDto("Lower-sugar digestive / oats biscuit", "Compare sugar per 100g on the label."));
        } else if (contains(blob, "cereal", "breakfast", "muesli")) {
            list.add(new AlternativeDto("Unsweetened oats", "Add fruit yourself to control sugar."));
            list.add(new AlternativeDto("High-fibre muesli (no candy bits)", "More fibre, fewer chocolate coatings."));
        } else {
            list.add(new AlternativeDto("Short-ingredient whole-food option", "Prefer recognizable ingredients near the top of the list."));
            list.add(new AlternativeDto("Lower sugar / salt sibling product", "Compare per 100g values side by side."));
            list.add(new AlternativeDto("Homemade version when practical", "You control oil, salt, and additives."));
        }

        boolean hasColor = flags != null && flags.stream()
                .anyMatch(f -> f.title().toLowerCase(Locale.ENGLISH).contains("color"));
        if (hasColor) {
            list.add(new AlternativeDto("Naturally colored alternative", "Avoid brightly dyed snacks when a plain option exists."));
        }

        return list.stream().distinct().limit(3).toList();
    }

    private static AnalysisPointDto point(String kind, String title, String detail) {
        return new AnalysisPointDto(title, detail, kind);
    }

    private static String normalizeGoal(String goal) {
        if (goal == null || goal.isBlank()) {
            return "LOSE_WEIGHT";
        }
        String g = goal.trim().toUpperCase(Locale.ENGLISH);
        if ("GAIN_MUSCLE".equals(g) || "MAINTAIN".equals(g) || "LOSE_WEIGHT".equals(g)) {
            return g;
        }
        return "LOSE_WEIGHT";
    }

    private static String goalLabel(String goal) {
        return switch (goal) {
            case "GAIN_MUSCLE" -> "muscle gain";
            case "MAINTAIN" -> "maintenance";
            default -> "weight loss";
        };
    }

    private static int clamp(int score) {
        return Math.max(0, Math.min(100, score));
    }

    private static boolean contains(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    private static List<AnalysisPointDto> limit(List<AnalysisPointDto> points, int max) {
        if (points.size() <= max) {
            return List.copyOf(points);
        }
        return List.copyOf(points.subList(0, max));
    }
}
