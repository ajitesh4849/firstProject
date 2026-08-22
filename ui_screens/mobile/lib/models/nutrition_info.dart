import 'food_intelligence.dart';

class NutritionInfo {
  const NutritionInfo({
    required this.foodName,
    required this.portionGrams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fibreGrams = 0,
    this.sugarGrams = 0,
    this.sodiumMg = 0,
    this.estimated = true,
    this.intelligence,
  });

  final String foodName;
  final int portionGrams;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fibreGrams;
  final double sugarGrams;
  final double sodiumMg;
  final bool estimated;
  final FoodIntelligence? intelligence;
}
