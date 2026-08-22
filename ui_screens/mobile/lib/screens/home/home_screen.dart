import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ux_states.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String? _error;
  TodaySummary? _today;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final today = await foodApi.fetchToday();
      if (!mounted) return;
      setState(() {
        _today = today;
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
        _error = 'Unable to load today’s summary right now.';
        _loading = false;
      });
    }
  }

  String _goalLabel(String goal) {
    switch (goal.toUpperCase()) {
      case 'GAIN_MUSCLE':
        return 'Muscle gain';
      case 'MAINTAIN':
        return 'Maintain';
      default:
        return 'Weight loss';
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    final consumed = today?.consumedKcal ?? 0;
    final goal = today?.goalKcal ?? 2200;
    final meals = today?.meals ?? const <Meal>[];
    final progress = goal == 0 ? 0.0 : consumed / goal;
    final remaining = math.max(0, goal - consumed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(current: MainTab.home),
      body: SafeArea(
        child: _loading
            ? const LoadingView(label: 'Loading today’s meals…')
            : _error != null
                ? ErrorState(
                    title: 'Couldn’t load Today',
                    message: _error!,
                    onRetry: _load,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.page,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (today != null) ...[
                            Text(
                              'Goal · ${_goalLabel(today.goal)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                          ],
                          AppCard(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 168,
                                  height: 168,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 168,
                                        height: 168,
                                        child: CircularProgressIndicator(
                                          value: progress.clamp(0.0, 1.0),
                                          strokeWidth: 12,
                                          backgroundColor: AppColors.border,
                                          color: AppColors.primary,
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$consumed',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                          Text(
                                            'of $goal kcal',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  remaining == 0
                                      ? 'Daily goal reached'
                                      : '$remaining kcal remaining',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                          if (today != null) ...[
                            const SizedBox(height: 14),
                            AppCard(
                              elevated: false,
                              child: Column(
                                children: [
                                  _MacroProgress(
                                    label: 'Protein',
                                    consumed: today.consumedProteinGrams,
                                    goal: today.goalProteinGrams,
                                    color: AppColors.primary,
                                    format: _fmt,
                                  ),
                                  const SizedBox(height: 14),
                                  _MacroProgress(
                                    label: 'Carbs',
                                    consumed: today.consumedCarbsGrams,
                                    goal: today.goalCarbsGrams,
                                    color: AppColors.accent,
                                    format: _fmt,
                                  ),
                                  const SizedBox(height: 14),
                                  _MacroProgress(
                                    label: 'Fat',
                                    consumed: today.consumedFatGrams,
                                    goal: today.goalFatGrams,
                                    color: const Color(0xFF5B8DEF),
                                    format: _fmt,
                                  ),
                                  const SizedBox(height: 14),
                                  _MacroProgress(
                                    label: 'Fibre',
                                    consumed: today.consumedFibreGrams,
                                    goal: today.goalFibreGrams,
                                    color: AppColors.success,
                                    format: _fmt,
                                  ),
                                  const SizedBox(height: 14),
                                  _MacroProgress(
                                    label: 'Sugar',
                                    consumed: today.consumedSugarGrams,
                                    goal: today.goalSugarGrams,
                                    color: AppColors.warning,
                                    format: _fmt,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          PrimaryButton(
                            label: 'Scan Food',
                            icon: Icons.camera_alt_outlined,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.scan);
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Meal photo or packaged food — choose inside Scan.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 22),
                          SectionHeader(
                            title: 'Meals',
                            subtitle: meals.isEmpty
                                ? 'Nothing logged yet'
                                : '${meals.length} logged today',
                          ),
                          const SizedBox(height: 12),
                          if (meals.isEmpty)
                            EmptyState(
                              title: 'No meals yet',
                              message:
                                  'Scan your first meal to start building today’s log.',
                              icon: Icons.restaurant_outlined,
                            )
                          else
                            ...meals.map(
                              (meal) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AppCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.md,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.restaurant_menu_rounded,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          meal.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      Text(
                                        '${meal.calories} kcal',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.primaryDark,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  const _MacroProgress({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    required this.format,
  });

  final String label;
  final double consumed;
  final double goal;
  final Color color;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final ratio = goal <= 0 ? 0.0 : consumed / goal;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(
              '${format(consumed)} / ${format(goal)}g',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: AppColors.border,
            color: color,
          ),
        ),
      ],
    );
  }
}
