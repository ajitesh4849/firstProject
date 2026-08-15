import 'ingredient_awareness.dart';

class FoodItem {
  const FoodItem({
    required this.name,
    required this.confidence,
    this.scanId,
    this.imageAsset,
    this.awareness,
  });

  final String name;
  final double confidence;
  final String? scanId;
  final String? imageAsset;
  final IngredientAwareness? awareness;

  IngredientAwareness get awarenessForDisplay =>
      awareness ?? IngredientAwareness.forFoodName(name);

  FoodItem copyWith({
    String? name,
    double? confidence,
    String? scanId,
    String? imageAsset,
    IngredientAwareness? awareness,
    bool clearAwareness = false,
  }) {
    final nextName = name ?? this.name;
    return FoodItem(
      name: nextName,
      confidence: confidence ?? this.confidence,
      scanId: scanId ?? this.scanId,
      imageAsset: imageAsset ?? this.imageAsset,
      awareness: clearAwareness
          ? IngredientAwareness.forFoodName(nextName)
          : (awareness ??
              (name != null
                  ? IngredientAwareness.forFoodName(nextName)
                  : this.awareness)),
    );
  }
}
