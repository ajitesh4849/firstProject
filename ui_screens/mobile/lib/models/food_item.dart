class FoodItem {
  const FoodItem({
    required this.name,
    required this.confidence,
    this.scanId,
    this.imageAsset,
  });

  final String name;
  final double confidence;
  final String? scanId;
  final String? imageAsset;

  FoodItem copyWith({
    String? name,
    double? confidence,
    String? scanId,
    String? imageAsset,
  }) {
    return FoodItem(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      scanId: scanId ?? this.scanId,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
