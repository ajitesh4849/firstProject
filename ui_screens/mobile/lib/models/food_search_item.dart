import 'nutrition_info.dart';

class FoodSearchItem {
  const FoodSearchItem({
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fibrePer100g,
    required this.sugarPer100g,
  });

  final String name;
  final String category;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fibrePer100g;
  final double sugarPer100g;

  NutritionInfo toServing(int grams) {
    final factor = grams / 100.0;
    return NutritionInfo(
      foodName: name,
      portionGrams: grams,
      calories: (caloriesPer100g * factor).round(),
      proteinGrams: _r1(proteinPer100g * factor),
      carbsGrams: _r1(carbsPer100g * factor),
      fatGrams: _r1(fatPer100g * factor),
      fibreGrams: _r1(fibrePer100g * factor),
      sugarGrams: _r1(sugarPer100g * factor),
      estimated: true,
    );
  }

  static double _r1(double v) => double.parse(v.toStringAsFixed(1));

  factory FoodSearchItem.fromJson(Map<String, dynamic> json) {
    return FoodSearchItem(
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'GENERAL',
      caloriesPer100g: (json['caloriesPer100g'] as num?)?.toInt() ?? 0,
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0,
      fibrePer100g: (json['fibrePer100g'] as num?)?.toDouble() ?? 0,
      sugarPer100g: (json['sugarPer100g'] as num?)?.toDouble() ?? 0,
    );
  }
}
