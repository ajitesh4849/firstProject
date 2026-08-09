class FoodItem {
  const FoodItem({
    required this.name,
    required this.confidence,
    this.imageAsset,
  });

  final String name;
  final double confidence;
  final String? imageAsset;

  FoodItem copyWith({
    String? name,
    double? confidence,
    String? imageAsset,
  }) {
    return FoodItem(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
