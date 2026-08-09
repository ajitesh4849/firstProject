import '../models/daily_summary.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/nutrition_info.dart';
import '../models/user_profile.dart';

/// Mock data + light session state for UI phases. No backend/AI calls.
class MockDataService {
  static const int dailyGoalKcal = 2200;

  static int consumedKcal = 1850;

  static final List<Meal> todayMeals = [
    const Meal(name: 'Breakfast', calories: 450),
    const Meal(name: 'Lunch', calories: 680),
    const Meal(name: 'Dinner', calories: 720),
  ];

  static const FoodItem detectedFood = FoodItem(
    name: 'Paneer Butter Masala',
    confidence: 0.92,
  );

  /// When true, the next scan simulation fails so error/retry UX can be tested.
  static bool forceNextScanFailure = false;

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

  static final List<DailySummary> history = [
    DailySummary(label: 'Mon', calories: 1900, date: DateTime(2026, 8, 3)),
    DailySummary(label: 'Tue', calories: 2100, date: DateTime(2026, 8, 4)),
    DailySummary(label: 'Wed', calories: 1750, date: DateTime(2026, 8, 5)),
    DailySummary(label: 'Thu', calories: 2000, date: DateTime(2026, 8, 6)),
    DailySummary(label: 'Fri', calories: 1850, date: DateTime(2026, 8, 7)),
    DailySummary(label: 'Sat', calories: 2300, date: DateTime(2026, 8, 8)),
    DailySummary(label: 'Sun', calories: 1850, date: DateTime(2026, 8, 9)),
  ];

  static double get weeklyAverage {
    if (history.isEmpty) return 0;
    final total = history.fold<int>(0, (sum, day) => sum + day.calories);
    return total / history.length;
  }

  static const UserProfile defaultProfile = UserProfile(
    age: 30,
    weightKg: 70,
    heightCm: 170,
    goal: FitnessGoal.loseWeight,
  );

  static void addMealToToday({
    required String name,
    required int calories,
  }) {
    todayMeals.add(Meal(name: name, calories: calories));
    consumedKcal += calories;
  }
}
