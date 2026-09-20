import 'food_intelligence.dart';
import 'nutrition_info.dart';

class PackagedRiskFlag {
  const PackagedRiskFlag({
    required this.code,
    required this.title,
    required this.severity,
    required this.detail,
  });

  final String code;
  final String title;
  final String severity;
  final String detail;

  factory PackagedRiskFlag.fromJson(Map<String, dynamic> json) {
    return PackagedRiskFlag(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'low',
      detail: json['detail']?.toString() ?? '',
    );
  }
}

class PackagedIngredientMark {
  const PackagedIngredientMark({
    required this.text,
    required this.tag,
    this.reason,
  });

  final String text;
  /// UNHEALTHY | HEALTHIER | NEUTRAL
  final String tag;
  final String? reason;

  bool get isUnhealthy => tag.toUpperCase() == 'UNHEALTHY';
  bool get isHealthier => tag.toUpperCase() == 'HEALTHIER';

  factory PackagedIngredientMark.fromJson(Map<String, dynamic> json) {
    return PackagedIngredientMark(
      text: json['text']?.toString() ?? '',
      tag: json['tag']?.toString() ?? 'NEUTRAL',
      reason: json['reason']?.toString(),
    );
  }
}

class AllergyWarning {
  const AllergyWarning({
    required this.code,
    required this.title,
    required this.detail,
  });

  final String code;
  final String title;
  final String detail;

  factory AllergyWarning.fromJson(Map<String, dynamic> json) {
    return AllergyWarning(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
    );
  }
}

class PackagedFoodAnalysis {
  const PackagedFoodAnalysis({
    required this.barcode,
    required this.productName,
    required this.found,
    required this.score,
    required this.riskCount,
    required this.flags,
    required this.healthierSwaps,
    required this.disclaimer,
    this.brand,
    this.quantity,
    this.ingredientsText,
    this.sugarPer100g,
    this.saltPer100g,
    this.energyKcalPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.fibrePer100g,
    this.saturatedFatPer100g,
    this.sodiumMgPer100g,
    this.source,
    this.canSaveToCatalog = false,
    this.ingredients = const [],
    this.intelligence,
    this.allergyWarnings = const [],
  });

  final String barcode;
  final String productName;
  final String? brand;
  final String? quantity;
  final String? ingredientsText;
  final double? sugarPer100g;
  final double? saltPer100g;
  final double? energyKcalPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final double? fibrePer100g;
  final double? saturatedFatPer100g;
  final double? sodiumMgPer100g;
  final String score;
  final int riskCount;
  final List<PackagedRiskFlag> flags;
  final List<String> healthierSwaps;
  final String disclaimer;
  final bool found;
  final String? source;
  final bool canSaveToCatalog;
  final List<PackagedIngredientMark> ingredients;
  final FoodIntelligence? intelligence;
  final List<AllergyWarning> allergyWarnings;

  bool get isFromLabelPhoto => source == 'LABEL_PHOTO';
  bool get isFromCatalog => source == 'SEED';

  /// True when we have enough per-100g data to log a serving.
  bool get canAddToToday =>
      energyKcalPer100g != null ||
      proteinPer100g != null ||
      carbsPer100g != null ||
      fatPer100g != null;

  NutritionInfo toServing(int grams) {
    final factor = grams / 100.0;
    final brandLabel = brand?.trim();
    final name = (brandLabel != null && brandLabel.isNotEmpty)
        ? '$productName ($brandLabel)'
        : productName;
    return NutritionInfo(
      foodName: name,
      portionGrams: grams,
      calories: ((energyKcalPer100g ?? 0) * factor).round(),
      proteinGrams: _r1((proteinPer100g ?? 0) * factor),
      carbsGrams: _r1((carbsPer100g ?? 0) * factor),
      fatGrams: _r1((fatPer100g ?? 0) * factor),
      fibreGrams: _r1((fibrePer100g ?? 0) * factor),
      sugarGrams: _r1((sugarPer100g ?? 0) * factor),
      sodiumMg: _r1((sodiumMgPer100g ?? ((saltPer100g ?? 0) * 400)) * factor),
      estimated: true,
      intelligence: intelligence,
    );
  }

  static double _r1(double v) => double.parse(v.toStringAsFixed(1));

  PackagedFoodAnalysis copyWith({
    String? barcode,
    String? productName,
    String? brand,
    String? quantity,
    String? ingredientsText,
    double? sugarPer100g,
    double? saltPer100g,
    double? energyKcalPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fibrePer100g,
    double? saturatedFatPer100g,
    double? sodiumMgPer100g,
    String? score,
    int? riskCount,
    List<PackagedRiskFlag>? flags,
    List<String>? healthierSwaps,
    String? disclaimer,
    bool? found,
    String? source,
    bool? canSaveToCatalog,
    List<PackagedIngredientMark>? ingredients,
    FoodIntelligence? intelligence,
    List<AllergyWarning>? allergyWarnings,
  }) {
    return PackagedFoodAnalysis(
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      ingredientsText: ingredientsText ?? this.ingredientsText,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      saltPer100g: saltPer100g ?? this.saltPer100g,
      energyKcalPer100g: energyKcalPer100g ?? this.energyKcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      fibrePer100g: fibrePer100g ?? this.fibrePer100g,
      saturatedFatPer100g: saturatedFatPer100g ?? this.saturatedFatPer100g,
      sodiumMgPer100g: sodiumMgPer100g ?? this.sodiumMgPer100g,
      score: score ?? this.score,
      riskCount: riskCount ?? this.riskCount,
      flags: flags ?? this.flags,
      healthierSwaps: healthierSwaps ?? this.healthierSwaps,
      disclaimer: disclaimer ?? this.disclaimer,
      found: found ?? this.found,
      source: source ?? this.source,
      canSaveToCatalog: canSaveToCatalog ?? this.canSaveToCatalog,
      ingredients: ingredients ?? this.ingredients,
      intelligence: intelligence ?? this.intelligence,
      allergyWarnings: allergyWarnings ?? this.allergyWarnings,
    );
  }

  factory PackagedFoodAnalysis.fromJson(Map<String, dynamic> json) {
    final flagsJson = json['flags'] as List<dynamic>? ?? [];
    final swapsJson = json['healthierSwaps'] as List<dynamic>? ?? [];
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];
    final warningsJson = json['allergyWarnings'] as List<dynamic>? ?? [];
    final intelligenceJson = json['intelligence'] as Map<String, dynamic>?;
    return PackagedFoodAnalysis(
      barcode: json['barcode']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Unknown product',
      brand: json['brand']?.toString(),
      quantity: json['quantity']?.toString(),
      ingredientsText: json['ingredientsText']?.toString(),
      sugarPer100g: (json['sugarPer100g'] as num?)?.toDouble(),
      saltPer100g: (json['saltPer100g'] as num?)?.toDouble(),
      energyKcalPer100g: (json['energyKcalPer100g'] as num?)?.toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble(),
      fatPer100g: (json['fatPer100g'] as num?)?.toDouble(),
      fibrePer100g: (json['fibrePer100g'] as num?)?.toDouble(),
      saturatedFatPer100g: (json['saturatedFatPer100g'] as num?)?.toDouble(),
      sodiumMgPer100g: (json['sodiumMgPer100g'] as num?)?.toDouble(),
      score: json['score']?.toString() ?? 'OK',
      riskCount: (json['riskCount'] as num?)?.toInt() ?? 0,
      flags: flagsJson
          .whereType<Map<String, dynamic>>()
          .map(PackagedRiskFlag.fromJson)
          .toList(),
      healthierSwaps: swapsJson.map((e) => e.toString()).toList(),
      disclaimer: json['disclaimer']?.toString() ??
          'Based on packaged product data and ingredient rules — not a lab test or medical advice.',
      found: json['found'] as bool? ?? true,
      source: json['source']?.toString(),
      canSaveToCatalog: json['canSaveToCatalog'] as bool? ?? false,
      ingredients: ingredientsJson
          .whereType<Map<String, dynamic>>()
          .map(PackagedIngredientMark.fromJson)
          .toList(),
      intelligence: intelligenceJson == null
          ? null
          : FoodIntelligence.fromJson(intelligenceJson),
      allergyWarnings: warningsJson
          .whereType<Map<String, dynamic>>()
          .map(AllergyWarning.fromJson)
          .toList(),
    );
  }
}
