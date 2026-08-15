import 'package:flutter/material.dart';

import '../../models/nutrition_info.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ux_states.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key, required this.nutrition});

  final NutritionInfo nutrition;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _isAdding = false;
  bool _added = false;

  Future<void> _addToToday() async {
    setState(() => _isAdding = true);
    try {
      await foodApi.addMeal(widget.nutrition);
      if (!mounted) return;
      setState(() {
        _isAdding = false;
        _added = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add meal to today')),
      );
    }
  }

  void _scanAnother() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
    Navigator.pushNamed(context, AppRoutes.scan);
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = widget.nutrition;
    final protein = nutrition.proteinGrams;
    final carbs = nutrition.carbsGrams;
    final fat = nutrition.fatGrams;
    final total = (protein + carbs + fat).clamp(1, 9999);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppSpacing.page,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        nutrition.foodName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${nutrition.portionGrams}g portion',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${nutrition.calories}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(color: AppColors.primaryDark),
                            ),
                            Text(
                              'kcal estimated',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          children: [
                            _MacroMeter(
                              label: 'Protein',
                              valueLabel: '${protein}g',
                              ratio: protein / total,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            _MacroMeter(
                              label: 'Carbs',
                              valueLabel: '${carbs}g',
                              ratio: carbs / total,
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: 16),
                            _MacroMeter(
                              label: 'Fat',
                              valueLabel: '${fat}g',
                              ratio: fat / total,
                              color: const Color(0xFF5B8DEF),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppConstants.nutritionDisclaimer,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_added) ...[
                        const SizedBox(height: 16),
                        const SuccessBanner(
                          message: 'Added to today. Returning home…',
                        ),
                      ],
                      const Spacer(),
                      PrimaryButton(
                        label: 'Add to Today',
                        icon: Icons.check_circle_outline,
                        isLoading: _isAdding,
                        onPressed: _added ? null : _addToToday,
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Scan another',
                        icon: Icons.camera_alt_outlined,
                        onPressed: _isAdding || _added ? null : _scanAnother,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MacroMeter extends StatelessWidget {
  const _MacroMeter({
    required this.label,
    required this.valueLabel,
    required this.ratio,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              valueLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.border,
            color: color,
          ),
        ),
      ],
    );
  }
}
