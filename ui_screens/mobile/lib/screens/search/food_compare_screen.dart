import 'package:flutter/material.dart';

import '../../models/comparable_food.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class FoodCompareScreen extends StatelessWidget {
  const FoodCompareScreen({
    super.key,
    required this.left,
    required this.right,
  });

  final ComparableFood left;
  final ComparableFood right;

  String _fmt(double? v) {
    if (v == null) return '—';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  Widget _header(BuildContext context, ComparableFood item) {
    return Expanded(
      child: Column(
        children: [
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.subtitle != null && item.subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            item.caloriesPer100g == null
                ? 'kcal n/a'
                : '${_fmt(item.caloriesPer100g)} kcal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (item.scoreLabel != null && item.scoreLabel!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Score ${item.scoreLabel}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required double? leftValue,
    required double? rightValue,
    bool highlightLower = false,
    bool highlightHigher = false,
  }) {
    Color? leftColor;
    Color? rightColor;
    if (leftValue != null && rightValue != null && leftValue != rightValue) {
      final leftWinsLower = leftValue < rightValue;
      final leftWinsHigher = leftValue > rightValue;
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
              _fmt(leftValue),
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
              _fmt(rightValue),
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
                      leftValue: left.caloriesPer100g,
                      rightValue: right.caloriesPer100g,
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Protein g',
                      leftValue: left.proteinPer100g,
                      rightValue: right.proteinPer100g,
                      highlightHigher: true,
                    ),
                    _row(
                      context,
                      label: 'Carbs g',
                      leftValue: left.carbsPer100g,
                      rightValue: right.carbsPer100g,
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Fat g',
                      leftValue: left.fatPer100g,
                      rightValue: right.fatPer100g,
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Fibre g',
                      leftValue: left.fibrePer100g,
                      rightValue: right.fibrePer100g,
                      highlightHigher: true,
                    ),
                    _row(
                      context,
                      label: 'Sugar g',
                      leftValue: left.sugarPer100g,
                      rightValue: right.sugarPer100g,
                      highlightLower: true,
                    ),
                    _row(
                      context,
                      label: 'Salt g',
                      leftValue: left.saltPer100g,
                      rightValue: right.saltPer100g,
                      highlightLower: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Green marks the better side when both values exist. Missing values show as —. Educational only.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SecondaryButton(
                label: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
