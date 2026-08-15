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
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EditFoodNameSheet(initialName: _food.name),
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
    final tone = confidencePct >= 80
        ? StatusChipTone.success
        : confidencePct >= 55
            ? StatusChipTone.warning
            : StatusChipTone.danger;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Detection')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FoodImagePlaceholder(
                height: 200,
                label: 'Detected dish',
              ),
              const SizedBox(height: 20),
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
  }
}

class _EditFoodNameSheet extends StatefulWidget {
  const _EditFoodNameSheet({required this.initialName});

  final String initialName;

  @override
  State<_EditFoodNameSheet> createState() => _EditFoodNameSheetState();
}

class _EditFoodNameSheetState extends State<_EditFoodNameSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context, _controller.text.trim());
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit food name',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Food name'),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
