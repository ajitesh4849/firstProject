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

  /// Split label text into readable rows and normalize ALL-CAPS walls of text.
  List<String> _ingredientItems(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*,\s*'), ', ')
        .trim();
    if (cleaned.isEmpty) return const [];

    final parts = cleaned
        .split(RegExp(r',\s*(?![^()]*\))'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      // Fallback: split on semicolons / periods if no useful commas.
      final alt = cleaned
          .split(RegExp(r'[;•|]'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      return (alt.length > 1 ? alt : [cleaned])
          .map(_readableIngredient)
          .toList();
    }
    return parts.map(_readableIngredient).toList();
  }

  String _readableIngredient(String value) {
    final text = value.trim();
    if (text.isEmpty) return text;

    // Keep short codes like E110 as-is; soften long ALL-CAPS labels.
    final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final mostlyUpper =
        letters.length >= 8 && letters == letters.toUpperCase();
    if (!mostlyUpper) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      // Preserve tokens like (71%), E110, MSG.
      if (RegExp(r'^[A-Z]?\d').hasMatch(word) ||
          RegExp(r'^\(?\d').hasMatch(word) ||
          word.length <= 3) {
        return word;
      }
      final lower = word.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).join(' ');
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
                      Builder(
                        builder: (context) {
                          final items =
                              _ingredientItems(analysis.ingredientsText!);
                          return AppCard(
                            padding:
                                const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < items.length; i++) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.full,
                                          ),
                                        ),
                                        child: Text(
                                          '${i + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.primaryDark,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          items[i],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.textPrimary,
                                                height: 1.45,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (i < items.length - 1)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(height: 1),
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
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
