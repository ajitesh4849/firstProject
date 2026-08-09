import '../models/daily_summary.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/nutrition_info.dart';
import '../models/user_profile.dart';

/// Local fallback helpers (used only if API is unreachable for nutrition scaling).
class MockDataService {
  static bool forceNextScanFailure = false;

  static const FoodItem detectedFood = FoodItem(
    name: 'Paneer Butter Masala',
    confidence: 0.92,
  );

  static const List<({String label, int grams})> portionOptions = [
    (label: 'Small', grams: 100),
    (label: 'Medium', grams: 200),
    (label: 'Large', grams: 300),
  ];

  static const double _kcalPer100g = 190;
  static const double _proteinPer100g = 7;
  static const double _carbsPer100g = 6;
  static const double _fatPer100g = 15;

  static NutritionInfo nutritionFor({
    required String foodName,
    required int portionGrams,
  }) {
    final factor = portionGrams / 100.0;
    return NutritionInfo(
      foodName: foodName,
      portionGrams: portionGrams,
      calories: (_kcalPer100g * factor).round(),
      proteinGrams: double.parse((_proteinPer100g * factor).toStringAsFixed(1)),
      carbsGrams: double.parse((_carbsPer100g * factor).toStringAsFixed(1)),
      fatGrams: double.parse((_fatPer100g * factor).toStringAsFixed(1)),
      estimated: true,
    );
  }

  static const UserProfile defaultProfile = UserProfile(
    age: 30,
    weightKg: 70,
    heightCm: 170,
    goal: FitnessGoal.loseWeight,
  );

  // Kept for type references in older UI paths if needed.
  static final List<Meal> todayMeals = <Meal>[];
  static final List<DailySummary> history = <DailySummary>[];
}
