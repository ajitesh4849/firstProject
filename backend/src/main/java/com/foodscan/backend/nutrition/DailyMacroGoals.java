package com.foodscan.backend.nutrition;

/**
 * Daily macro targets derived from calorie goal (simple MVP ratios).
 */
public final class DailyMacroGoals {

    private DailyMacroGoals() {
    }

    public static Targets fromCalorieGoal(int goalKcal) {
        int kcal = Math.max(1200, goalKcal);
        double protein = round1(kcal * 0.25 / 4.0);
        double carbs = round1(kcal * 0.45 / 4.0);
        double fat = round1(kcal * 0.30 / 9.0);
        double fibre = 30.0;
        double sugar = round1(Math.min(50.0, kcal * 0.10 / 4.0));
        return new Targets(protein, carbs, fat, fibre, sugar);
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    public record Targets(
            double proteinGrams,
            double carbsGrams,
            double fatGrams,
            double fibreGrams,
            double sugarGrams
    ) {
    }
}
