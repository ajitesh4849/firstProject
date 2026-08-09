class DailySummary {
  const DailySummary({
    required this.label,
    required this.calories,
    this.date,
  });

  final String label;
  final int calories;
  final DateTime? date;
}
