import 'package:flutter/material.dart';

import '../../models/nutrition_info.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
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
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    MockDataService.addMealToToday(
      name: widget.nutrition.foodName,
      calories: widget.nutrition.calories,
    );

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

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
              const SizedBox(height: 28),
              Text(
                '${nutrition.calories} kcal',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  children: [
                    _MacroRow(label: 'Protein', value: '${nutrition.proteinGrams}g'),
                    const Divider(height: 24, color: AppColors.border),
                    _MacroRow(label: 'Carbs', value: '${nutrition.carbsGrams}g'),
                    const Divider(height: 24, color: AppColors.border),
                    _MacroRow(label: 'Fat', value: '${nutrition.fatGrams}g'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.nutritionDisclaimer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              if (_added) ...[
                const SizedBox(height: 16),
                const SuccessBanner(message: 'Added to today. Returning home…'),
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
                label: 'Scan Another',
                icon: Icons.camera_alt_outlined,
                onPressed: _isAdding || _added ? null : _scanAnother,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryDark,
              ),
        ),
      ],
    );
  }
}
