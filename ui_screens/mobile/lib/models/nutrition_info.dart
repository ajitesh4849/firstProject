class NutritionInfo {
  const NutritionInfo({
    required this.foodName,
    required this.portionGrams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.estimated = true,
  });

  final String foodName;
  final int portionGrams;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final bool estimated;
}
