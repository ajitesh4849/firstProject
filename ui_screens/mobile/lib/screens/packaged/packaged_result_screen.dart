import 'package:flutter/material.dart';

import '../../models/packaged_food_analysis.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class PackagedResultScreen extends StatelessWidget {
  const PackagedResultScreen({super.key, required this.analysis});

  final PackagedFoodAnalysis analysis;

  Color _scoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'BETTER':
        return AppColors.success;
      case 'CAUTION':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(analysis.score);

    return Scaffold(
      appBar: AppBar(title: const Text('Packaged check')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.productName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (analysis.brand != null &&
                              analysis.brand!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              analysis.brand!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Barcode ${analysis.barcode}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              border: Border.all(
                                color: scoreColor.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'Score: ${analysis.score}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: scoreColor),
                            ),
                          ),
                          if (analysis.energyKcalPer100g != null ||
                              analysis.sugarPer100g != null ||
                              analysis.saltPer100g != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              [
                                if (analysis.energyKcalPer100g != null)
                                  '${analysis.energyKcalPer100g!.round()} kcal/100g',
                                if (analysis.sugarPer100g != null)
                                  'Sugar ${analysis.sugarPer100g!.toStringAsFixed(1)}g/100g',
                                if (analysis.saltPer100g != null)
                                  'Salt ${analysis.saltPer100g!.toStringAsFixed(2)}g/100g',
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Flags (${analysis.riskCount})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    if (analysis.flags.isEmpty)
                      AppCard(
                        child: Text(
                          'No major rule-based concerns found for this product.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...analysis.flags.map(
                        (flag) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: _severityColor(flag.severity),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        flag.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        flag.detail,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${flag.code} · ${flag.severity}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Healthier swaps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final swap in analysis.healthierSwaps) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.eco_outlined,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    swap,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (swap != analysis.healthierSwaps.last)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    if (analysis.ingredientsText != null &&
                        analysis.ingredientsText!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      AppCard(
                        child: Text(
                          analysis.ingredientsText!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      analysis.disclaimer,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: 'Scan another package',
                    icon: Icons.qr_code_scanner_rounded,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.packagedBarcode,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Back to Scan',
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.scan,
                        (route) =>
                            route.settings.name == AppRoutes.home ||
                            route.isFirst,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
