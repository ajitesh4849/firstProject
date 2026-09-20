import 'package:flutter/material.dart';

import '../models/food_intelligence.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import 'app_card.dart';

class FoodIntelligenceCard extends StatelessWidget {
  const FoodIntelligenceCard({super.key, required this.intelligence});

  final FoodIntelligence intelligence;

  Color _scoreColor(int score) {
    if (score >= 75) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(intelligence.healthScore);
    final personalColor = _scoreColor(intelligence.personalizedScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Row(
            children: [
              _ScoreRing(
                score: intelligence.healthScore,
                label: intelligence.bandLabel,
                color: scoreColor,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${intelligence.healthScore}/100 · ${intelligence.bandLabel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scoreColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'For your goal (${intelligence.goalLabel})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${intelligence.personalizedScore}/100',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: personalColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (intelligence.personalizedVerdict.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            elevated: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    intelligence.personalizedVerdict,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (intelligence.good.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Good', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...intelligence.good.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PointTile(point: p, positive: true),
            ),
          ),
        ],
        if (intelligence.watch.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Watch', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...intelligence.watch.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PointTile(point: p, positive: false),
            ),
          ),
        ],
        if (intelligence.alternatives.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Smarter swaps', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Practical upgrades — not medical advice.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ...List.generate(intelligence.alternatives.length, (index) {
            final alt = intelligence.alternatives[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SwapTile(
                index: index + 1,
                name: alt.name,
                reason: alt.reason,
                onFind: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.foodSearch,
                    arguments: alt.name,
                  );
                },
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _SwapTile extends StatelessWidget {
  const _SwapTile({
    required this.index,
    required this.name,
    required this.reason,
    required this.onFind,
  });

  final int index;
  final String name;
  final String reason;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FADF),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search this food',
            onPressed: onFind,
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.label,
    required this.color,
  });

  final int score;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CircularProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: AppColors.border,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
              ),
              Text(
                '/100',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  const _PointTile({required this.point, required this.positive});

  final AnalysisPoint point;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.warning;
    return AppCard(
      elevated: false,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(point.detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
