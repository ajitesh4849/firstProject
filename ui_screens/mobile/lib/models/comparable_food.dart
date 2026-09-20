import 'food_search_item.dart';
import 'packaged_food_analysis.dart';

/// Normalized side for the compare screen (catalog meal or packaged product).
class ComparableFood {
  const ComparableFood({
    required this.id,
    required this.title,
    this.subtitle,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.fibrePer100g,
    this.sugarPer100g,
    this.saltPer100g,
    this.scoreLabel,
  });

  final String id;
  final String title;
  final String? subtitle;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final double? fibrePer100g;
  final double? sugarPer100g;
  final double? saltPer100g;
  final String? scoreLabel;

  factory ComparableFood.fromSearchItem(FoodSearchItem item) {
    return ComparableFood(
      id: 'food:${item.name}',
      title: item.name,
      subtitle: item.category,
      caloriesPer100g: item.caloriesPer100g.toDouble(),
      proteinPer100g: item.proteinPer100g,
      carbsPer100g: item.carbsPer100g,
      fatPer100g: item.fatPer100g,
      fibrePer100g: item.fibrePer100g,
      sugarPer100g: item.sugarPer100g,
    );
  }

  factory ComparableFood.fromPackaged(PackagedFoodAnalysis item) {
    final brand = item.brand?.trim();
    return ComparableFood(
      id: 'packaged:${item.barcode}',
      title: item.productName,
      subtitle: (brand != null && brand.isNotEmpty) ? brand : item.barcode,
      caloriesPer100g: item.energyKcalPer100g,
      proteinPer100g: item.proteinPer100g,
      carbsPer100g: item.carbsPer100g,
      fatPer100g: item.fatPer100g,
      fibrePer100g: item.fibrePer100g,
      sugarPer100g: item.sugarPer100g,
      saltPer100g: item.saltPer100g,
      scoreLabel: item.score,
    );
  }
}
