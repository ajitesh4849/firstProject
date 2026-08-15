import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/food_image_placeholder.dart';
import '../../widgets/primary_button.dart';

class FoodResultScreen extends StatefulWidget {
  const FoodResultScreen({super.key, this.food});

  final FoodItem? food;

  @override
  State<FoodResultScreen> createState() => _FoodResultScreenState();
}

class _FoodResultScreenState extends State<FoodResultScreen> {
  late FoodItem _food;

  @override
  void initState() {
    super.initState();
    _food = widget.food ?? MockDataService.detectedFood;
  }

  Future<void> _editFoodName() async {
    final controller = TextEditingController(text: _food.name);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          title: const Text('Edit food name'),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Food name'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null) return;
    if (result.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food name cannot be empty')),
      );
      return;
    }
    setState(() => _food = _food.copyWith(name: result));
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct = (_food.confidence * 100).round();
    final tone = confidencePct >= 80
        ? StatusChipTone.success
        : confidencePct >= 55
            ? StatusChipTone.warning
            : StatusChipTone.danger;

    // Keep scaffold from shrinking under the keyboard while the edit dialog is open.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Detection')),
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
                      const FoodImagePlaceholder(
                        height: 240,
                        label: 'Detected dish',
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              _food.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 14),
                            StatusChip(
                              label: 'Confidence $confidencePct%',
                              tone: tone,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Confirm the dish before estimating nutrition.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: 'Looks correct',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.portion,
                            arguments: _food,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Edit food name',
                        icon: Icons.edit_outlined,
                        onPressed: _editFoodName,
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
