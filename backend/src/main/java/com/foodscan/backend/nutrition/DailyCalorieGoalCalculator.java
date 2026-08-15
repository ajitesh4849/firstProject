package com.foodscan.backend.nutrition;

import org.springframework.stereotype.Component;

/**
 * Daily calorie target from Mifflin-St Jeor BMR × activity × goal adjustment.
 * Educational tracking only — not medical advice.
 */
@Component
public class DailyCalorieGoalCalculator {

    public int calculate(
            int age,
            double weightKg,
            double heightCm,
            String gender,
            String activityLevel,
            String goal
    ) {
        double bmr = mifflinStJeor(age, weightKg, heightCm, gender);
        double maintenance = bmr * activityMultiplier(activityLevel);

        String normalizedGoal = goal == null ? "LOSE_WEIGHT" : goal.trim().toUpperCase();
        double target = switch (normalizedGoal) {
            case "MAINTAIN" -> maintenance;
            case "GAIN_MUSCLE" -> maintenance + 300;
            case "LOSE_WEIGHT" -> maintenance - 400;
            default -> maintenance - 400;
        };

        return (int) Math.round(clamp(target, 1200, 4000));
    }

    private static double mifflinStJeor(int age, double weightKg, double heightCm, String gender) {
        String normalized = gender == null ? "UNSPECIFIED" : gender.trim().toUpperCase();
        double sexConstant = switch (normalized) {
            case "MALE" -> 5.0;
            case "FEMALE" -> -161.0;
            default -> -78.0; // midpoint when unspecified
        };
        return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) + sexConstant;
    }

    private static double activityMultiplier(String activityLevel) {
        String normalized = activityLevel == null ? "SEDENTARY" : activityLevel.trim().toUpperCase();
        return switch (normalized) {
            case "LIGHTLY_ACTIVE" -> 1.375;
            case "MODERATELY_ACTIVE" -> 1.55;
            case "VERY_ACTIVE" -> 1.725;
            case "SEDENTARY" -> 1.2;
            default -> 1.2;
        };
    }

    private static double clamp(double value, double min, double max) {
        return Math.max(min, Math.min(max, value));
    }
}
