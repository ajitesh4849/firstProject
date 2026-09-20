package com.foodscan.backend.nutrition;

/**
 * Short rule-based coaching line for Home — no LLM, no extra DB reads.
 */
public final class DailyTipBuilder {

    private DailyTipBuilder() {
    }

    public static String build(
            int consumedKcal,
            int goalKcal,
            double protein,
            double goalProtein,
            double fibre,
            double goalFibre,
            double sugar,
            double goalSugar,
            int mealCount,
            String goal
    ) {
        if (mealCount == 0) {
            return "Scan a meal or packaged snack to start today’s log.";
        }
        if (protein < goalProtein * 0.45 && consumedKcal > goalKcal * 0.35) {
            return "Protein looks low so far — try dal, eggs, curd, or paneer at the next meal.";
        }
        if (fibre < goalFibre * 0.4 && mealCount >= 2) {
            return "Add vegetables, fruit, or whole grains to lift fibre for the day.";
        }
        if (sugar > goalSugar * 0.85) {
            return "Sugar is climbing — swap one sweet snack for fruit or nuts if you can.";
        }
        if ("LOSE_WEIGHT".equals(goal) && consumedKcal > goalKcal) {
            return "You’re over today’s calorie target — a lighter dinner can still balance the day.";
        }
        if ("GAIN_MUSCLE".equals(goal) && protein >= goalProtein * 0.8) {
            return "Strong protein day so far — keep portions consistent.";
        }
        if (consumedKcal >= goalKcal * 0.9 && consumedKcal <= goalKcal * 1.05) {
            return "You’re close to today’s calorie target — nice pacing.";
        }
        return "Keep logging — small consistent scans beat perfect guesses.";
    }
}
