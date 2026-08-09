import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Food Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Food name'),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

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

    return Scaffold(
      appBar: AppBar(title: const Text('Food Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FoodImagePlaceholder(
                height: 240,
                label: 'Detected dish',
              ),
              const SizedBox(height: 24),
              Text(
                _food.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Confidence: $confidencePct%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Looks Correct',
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
                label: 'Edit Food Name',
                icon: Icons.edit_outlined,
                onPressed: _editFoodName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
