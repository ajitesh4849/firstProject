import 'dart:typed_data';

class FoodCandidate {
  const FoodCandidate({
    required this.foodName,
    required this.confidence,
    this.category = 'GENERAL',
  });

  final String foodName;
  final double confidence;
  final String category;

  int get confidencePercent => (confidence * 100).round().clamp(0, 100);

  factory FoodCandidate.fromJson(Map<String, dynamic> json) {
    return FoodCandidate(
      foodName: json['foodName']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      category: json['category']?.toString() ?? 'GENERAL',
    );
  }
}

class ScanResult {
  const ScanResult({
    required this.scanId,
    required this.identifierMode,
    required this.needsUserPick,
    this.food,
    this.candidates = const [],
  });

  final String scanId;
  final String identifierMode;
  final bool needsUserPick;
  final FoodItemRef? food;
  final List<FoodCandidate> candidates;

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final foodJson = json['food'] as Map<String, dynamic>?;
    final candidatesJson = json['candidates'] as List<dynamic>? ?? [];
    return ScanResult(
      scanId: json['scanId']?.toString() ?? '',
      identifierMode: json['identifierMode']?.toString() ?? 'catalog',
      needsUserPick: json['needsUserPick'] as bool? ?? true,
      food: foodJson == null ? null : FoodItemRef.fromJson(foodJson),
      candidates: candidatesJson
          .whereType<Map<String, dynamic>>()
          .map(FoodCandidate.fromJson)
          .toList(),
    );
  }
}

class FoodItemRef {
  const FoodItemRef({
    required this.name,
    required this.confidence,
    this.awareness,
  });

  final String name;
  final double confidence;
  final Map<String, dynamic>? awareness;

  factory FoodItemRef.fromJson(Map<String, dynamic> json) {
    return FoodItemRef(
      name: json['name']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      awareness: json['awareness'] as Map<String, dynamic>?,
    );
  }
}

class FoodMatchArgs {
  const FoodMatchArgs({
    required this.scanId,
    required this.imageBytes,
    this.filename = 'meal.jpg',
    this.initialCandidates = const [],
    this.identifierMode = 'catalog',
  });

  final String scanId;
  final Uint8List imageBytes;
  final String filename;
  final List<FoodCandidate> initialCandidates;
  final String identifierMode;
}
