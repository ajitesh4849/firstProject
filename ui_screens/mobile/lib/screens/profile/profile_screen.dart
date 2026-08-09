import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_profile.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
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
  FitnessGoal _goal = FitnessGoal.loseWeight;
  bool _loading = true;
  bool _isSaving = false;
  bool _saved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = MockDataService.defaultProfile;
    _ageController = TextEditingController(text: '${profile.age}');
    _weightController = TextEditingController(text: '${profile.weightKg.round()}');
    _heightController = TextEditingController(text: '${profile.heightCm.round()}');
    _load();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await foodApi.fetchProfile();
      if (!mounted) return;
      setState(() {
        _ageController.text = '${profile.age}';
        _weightController.text = '${profile.weightKg.round()}';
        _heightController.text = '${profile.heightCm.round()}';
        _goal = profile.goal;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load profile right now.';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saved = false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await foodApi.updateProfile(
        UserProfile(
          age: int.parse(_ageController.text.trim()),
          weightKg: double.parse(_weightController.text.trim()),
          heightCm: double.parse(_heightController.text.trim()),
          goal: _goal,
        ),
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saved = true;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading || _isSaving ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(current: MainTab.profile),
      body: SafeArea(
        child: _loading
            ? const LoadingView(label: 'Loading profile…')
            : _error != null
                ? ErrorState(
                    title: 'Couldn’t load Profile',
                    message: _error!,
                    onRetry: _load,
                  )
                : GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      padding: AppSpacing.page,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_saved) ...[
                              const SuccessBanner(
                                message: 'Profile updated successfully.',
                              ),
                              const SizedBox(height: 16),
                            ],
                            const SectionHeader(
                              title: 'Body metrics',
                              subtitle: 'Used only for personal tracking',
                            ),
                            const SizedBox(height: 12),
                            AppCard(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _ageController,
                                    enabled: !_isSaving,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Weight',
                                      suffixText: 'kg',
                                      prefixIcon:
                                          Icon(Icons.monitor_weight_outlined),
                                    ),
                                    validator: (value) {
                                      final weight = int.tryParse(value ?? '');
                                      if (weight == null ||
                                          weight < 20 ||
                                          weight > 400) {
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Height',
                                      suffixText: 'cm',
                                      prefixIcon: Icon(Icons.height_outlined),
                                    ),
                                    validator: (value) {
                                      final height = int.tryParse(value ?? '');
                                      if (height == null ||
                                          height < 80 ||
                                          height > 250) {
                                        return 'Enter a valid height';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            const SectionHeader(title: 'Goal'),
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
                                      Expanded(
                                        child: Text(
                                          goal.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            Text(
                              'Goals are for tracking only — not medical advice.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: 'Save changes',
                              isLoading: _isSaving,
                              onPressed: _save,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
