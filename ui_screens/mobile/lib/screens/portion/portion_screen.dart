import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/food_item.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class PortionScreen extends StatefulWidget {
  const PortionScreen({super.key, required this.food});

  final FoodItem food;

  @override
  State<PortionScreen> createState() => _PortionScreenState();
}

class _PortionScreenState extends State<PortionScreen> {
  int _selectedIndex = 1;
  final _customController = TextEditingController();
  bool _useCustom = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _portionGrams {
    if (_useCustom) {
      final value = int.tryParse(_customController.text.trim());
      if (value == null || value <= 0) return null;
      return value;
    }
    return MockDataService.portionOptions[_selectedIndex].grams;
  }

  void _continue() {
    final grams = _portionGrams;
    if (grams == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid custom portion in grams')),
      );
      return;
    }

    final nutrition = MockDataService.nutritionFor(
      foodName: widget.food.name,
      portionGrams: grams,
    );

    Navigator.pushNamed(
      context,
      AppRoutes.nutrition,
      arguments: nutrition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Portion')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.food.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a portion size for estimation',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ...List.generate(MockDataService.portionOptions.length, (index) {
                final option = MockDataService.portionOptions[index];
                final selected = !_useCustom && _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () {
                      setState(() {
                        _useCustom = false;
                        _selectedIndex = index;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${option.grams}g',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primaryDark,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              AppCard(
                onTap: () => setState(() => _useCustom = true),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _useCustom
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _useCustom
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Custom grams',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customController,
                      enabled: _useCustom,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'e.g. 250',
                        suffixText: 'g',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
