import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_profile.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ux_states.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late FitnessGoal _goal;
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final profile = MockDataService.defaultProfile;
    _ageController = TextEditingController(text: '${profile.age}');
    _weightController = TextEditingController(text: '${profile.weightKg.round()}');
    _heightController = TextEditingController(text: '${profile.heightCm.round()}');
    _goal = profile.goal;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saved = false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _saved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const MainBottomNav(current: MainTab.profile),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_saved) ...[
                  const SuccessBanner(message: 'Profile saved (mock).'),
                  const SizedBox(height: 16),
                ],
                AppCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _ageController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        validator: (value) {
                          final age = int.tryParse(value ?? '');
                          if (age == null || age < 10 || age > 120) {
                            return 'Enter a valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _weightController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          suffixText: 'kg',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        validator: (value) {
                          final weight = int.tryParse(value ?? '');
                          if (weight == null || weight < 20 || weight > 400) {
                            return 'Enter a valid weight';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _heightController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          suffixText: 'cm',
                          prefixIcon: Icon(Icons.height_outlined),
                        ),
                        validator: (value) {
                          final height = int.tryParse(value ?? '');
                          if (height == null || height < 80 || height > 250) {
                            return 'Enter a valid height';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Goal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...FitnessGoal.values.map((goal) {
                  final selected = _goal == goal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: _isSaving
                          ? null
                          : () => setState(() {
                                _goal = goal;
                                _saved = false;
                              }),
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
                          Text(
                            goal.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text(
                  'Goals are for tracking only. No medical recommendations yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
