class AnalysisPoint {
  const AnalysisPoint({
    required this.title,
    required this.detail,
    required this.kind,
  });

  final String title;
  final String detail;

  /// GOOD | WATCH
  final String kind;

  bool get isGood => kind.toUpperCase() == 'GOOD';
  bool get isWatch => kind.toUpperCase() == 'WATCH';

  factory AnalysisPoint.fromJson(Map<String, dynamic> json) {
    return AnalysisPoint(
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'WATCH',
    );
  }
}

class FoodAlternative {
  const FoodAlternative({
    required this.name,
    required this.reason,
  });

  final String name;
  final String reason;

  factory FoodAlternative.fromJson(Map<String, dynamic> json) {
    return FoodAlternative(
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class FoodIntelligence {
  const FoodIntelligence({
    required this.healthScore,
    required this.healthBand,
    required this.good,
    required this.watch,
    required this.personalizedScore,
    required this.personalizedVerdict,
    required this.goal,
    required this.alternatives,
  });

  final int healthScore;
  final String healthBand;
  final List<AnalysisPoint> good;
  final List<AnalysisPoint> watch;
  final int personalizedScore;
  final String personalizedVerdict;
  final String goal;
  final List<FoodAlternative> alternatives;

  String get bandLabel {
    switch (healthBand.toUpperCase()) {
      case 'EXCELLENT':
        return 'Excellent';
      case 'GOOD':
        return 'Good';
      case 'MODERATE':
        return 'Moderate';
      case 'OCCASIONAL':
        return 'Occasional';
      case 'POOR':
        return 'Poor choice';
      default:
        return healthBand;
    }
  }

  String get goalLabel {
    switch (goal.toUpperCase()) {
      case 'GAIN_MUSCLE':
        return 'Muscle gain';
      case 'MAINTAIN':
        return 'Maintain';
      default:
        return 'Weight loss';
    }
  }

  factory FoodIntelligence.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FoodIntelligence(
        healthScore: 0,
        healthBand: 'MODERATE',
        good: [],
        watch: [],
        personalizedScore: 0,
        personalizedVerdict: '',
        goal: 'LOSE_WEIGHT',
        alternatives: [],
      );
    }
    final goodJson = json['good'] as List<dynamic>? ?? [];
    final watchJson = json['watch'] as List<dynamic>? ?? [];
    final altJson = json['alternatives'] as List<dynamic>? ?? [];
    return FoodIntelligence(
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 0,
      healthBand: json['healthBand']?.toString() ?? 'MODERATE',
      good: goodJson
          .whereType<Map<String, dynamic>>()
          .map(AnalysisPoint.fromJson)
          .toList(),
      watch: watchJson
          .whereType<Map<String, dynamic>>()
          .map(AnalysisPoint.fromJson)
          .toList(),
      personalizedScore: (json['personalizedScore'] as num?)?.toInt() ?? 0,
      personalizedVerdict: json['personalizedVerdict']?.toString() ?? '',
      goal: json['goal']?.toString() ?? 'LOSE_WEIGHT',
      alternatives: altJson
          .whereType<Map<String, dynamic>>()
          .map(FoodAlternative.fromJson)
          .toList(),
    );
  }
}
