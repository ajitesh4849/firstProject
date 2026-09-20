import 'package:flutter/material.dart';

import '../../models/food_search_item.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class FoodCompareScreen extends StatelessWidget {
  const FoodCompareScreen({
    super.key,
    required this.left,
    required this.right,
  });

  final FoodSearchItem left;
  final FoodSearchItem right;

  String _fmt(num v) {
    if (v is int) return '$v';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(1);
  }

  Widget _header(BuildContext context, FoodSearchItem item) {
    return Expanded(
      child: Column(
        children: [
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${item.caloriesPer100g} kcal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String leftValue,
    required String rightValue,
    bool highlightLower = false,
    bool highlightHigher = false,
  }) {
    final leftNum = double.tryParse(leftValue);
    final rightNum = double.tryParse(rightValue);
    Color? leftColor;
    Color? rightColor;
    if (leftNum != null && rightNum != null && leftNum != rightNum) {
      final leftWinsLower = leftNum < rightNum;
      final leftWinsHigher = leftNum > rightNum;
      if (highlightLower) {
        leftColor = leftWinsLower ? AppColors.success : null;
        rightColor = !leftWinsLower ? AppColors.success : null;
      } else if (highlightHigher) {
        leftColor = leftWinsHigher ? AppColors.success : null;
        rightColor = !leftWinsHigher ? AppColors.success : null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              leftValue,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: leftColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              rightValue,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: rightColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Per 100g',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context, left),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.compare_arrows_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        _header(context, right),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    _row(
                      context,
                      label: 'Calories',
                      leftValue: _fmt(left.caloriesPer100g),
                      rightValue: _fmt(right.caloriesPer100g),
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Protein g',
                      leftValue: _fmt(left.proteinPer100g),
                      rightValue: _fmt(right.proteinPer100g),
                      highlightHigher: true,
                    ),
                    _row(
                      context,
                      label: 'Carbs g',
                      leftValue: _fmt(left.carbsPer100g),
                      rightValue: _fmt(right.carbsPer100g),
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Fat g',
                      leftValue: _fmt(left.fatPer100g),
                      rightValue: _fmt(right.fatPer100g),
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Fibre g',
                      leftValue: _fmt(left.fibrePer100g),
                      rightValue: _fmt(right.fibrePer100g),
                      highlightHigher: true,
                    ),
                    _row(
                      context,
                      label: 'Sugar g',
                      leftValue: _fmt(left.sugarPer100g),
                      rightValue: _fmt(right.sugarPer100g),
                      highlightLower: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Green marks the better side for each row (lower calories/sugar/fat/carbs, higher protein/fibre). Educational only.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SecondaryButton(
                label: 'Back to search',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
