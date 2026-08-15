import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/food_item.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
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
  bool _loading = false;

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

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    final grams = _portionGrams;
    if (grams == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid custom portion in grams')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final scanId = widget.food.scanId;
      final nutrition = (scanId == null || scanId.isEmpty)
          ? MockDataService.nutritionFor(
              foodName: widget.food.name,
              portionGrams: grams,
            )
          : await foodApi.fetchNutrition(scanId: scanId, portionGrams: grams);

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.nutrition,
        arguments: nutrition,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not estimate nutrition')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portion')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: widget.food.name,
                  subtitle: 'Choose a portion size for estimation',
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      ...List.generate(MockDataService.portionOptions.length,
                          (index) {
                        final option = MockDataService.portionOptions[index];
                        final selected = !_useCustom && _selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            onTap: _loading
                                ? null
                                : () {
                                    FocusScope.of(context).unfocus();
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
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  '${option.grams}g',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      AppCard(
                        onTap: _loading
                            ? null
                            : () => setState(() => _useCustom = true),
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _customController,
                              enabled: _useCustom && !_loading,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _continue(),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                hintText: 'e.g. 250',
                                suffixText: 'g',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      // Keep the custom field above the keyboard when focused.
                      SizedBox(
                        height: MediaQuery.viewInsetsOf(context).bottom > 0
                            ? 24
                            : 0,
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Continue',
                  isLoading: _loading,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
