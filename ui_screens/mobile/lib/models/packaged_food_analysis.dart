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
    this.source,
    this.canSaveToCatalog = false,
  });

  final String barcode;
  final String productName;
  final String? brand;
  final String? quantity;
  final String? ingredientsText;
  final double? sugarPer100g;
  final double? saltPer100g;
  final double? energyKcalPer100g;
  final String score;
  final int riskCount;
  final List<PackagedRiskFlag> flags;
  final List<String> healthierSwaps;
  final String disclaimer;
  final bool found;
  final String? source;
  final bool canSaveToCatalog;

  bool get isFromLabelPhoto => source == 'LABEL_PHOTO';
  bool get isFromCatalog => source == 'SEED';

  PackagedFoodAnalysis copyWith({
    String? barcode,
    String? productName,
    String? brand,
    String? quantity,
    String? ingredientsText,
    double? sugarPer100g,
    double? saltPer100g,
    double? energyKcalPer100g,
    String? score,
    int? riskCount,
    List<PackagedRiskFlag>? flags,
    List<String>? healthierSwaps,
    String? disclaimer,
    bool? found,
    String? source,
    bool? canSaveToCatalog,
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
      score: score ?? this.score,
      riskCount: riskCount ?? this.riskCount,
      flags: flags ?? this.flags,
      healthierSwaps: healthierSwaps ?? this.healthierSwaps,
      disclaimer: disclaimer ?? this.disclaimer,
      found: found ?? this.found,
      source: source ?? this.source,
      canSaveToCatalog: canSaveToCatalog ?? this.canSaveToCatalog,
    );
  }

  factory PackagedFoodAnalysis.fromJson(Map<String, dynamic> json) {
    final flagsJson = json['flags'] as List<dynamic>? ?? [];
    final swapsJson = json['healthierSwaps'] as List<dynamic>? ?? [];
    return PackagedFoodAnalysis(
      barcode: json['barcode']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Unknown product',
      brand: json['brand']?.toString(),
      quantity: json['quantity']?.toString(),
      ingredientsText: json['ingredientsText']?.toString(),
      sugarPer100g: (json['sugarPer100g'] as num?)?.toDouble(),
      saltPer100g: (json['saltPer100g'] as num?)?.toDouble(),
      energyKcalPer100g: (json['energyKcalPer100g'] as num?)?.toDouble(),
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
    );
  }
}
