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
  int _consumed = 0;
  int _goal = 2200;
  List<Meal> _meals = const [];

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
        _consumed = today.consumedKcal;
        _goal = today.goalKcal;
        _meals = today.meals;
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

  @override
  Widget build(BuildContext context) {
    final progress = _goal == 0 ? 0.0 : _consumed / _goal;
    final remaining = math.max(0, _goal - _consumed);

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
                                            '$_consumed',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                          Text(
                                            'of $_goal kcal',
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
                          const SizedBox(height: 22),
                          SectionHeader(
                            title: 'Meals',
                            subtitle: _meals.isEmpty
                                ? 'Nothing logged yet'
                                : '${_meals.length} logged today',
                          ),
                          const SizedBox(height: 12),
                          if (_meals.isEmpty)
                            EmptyState(
                              title: 'No meals yet',
                              message:
                                  'Scan your first meal to start building today’s log.',
                              icon: Icons.restaurant_outlined,
                              actionLabel: 'Scan Food',
                              onAction: () {
                                Navigator.pushNamed(context, AppRoutes.scan);
                              },
                            )
                          else ...[
                            ..._meals.map(
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
                            const SizedBox(height: 18),
                            PrimaryButton(
                              label: 'Scan Food',
                              icon: Icons.camera_alt_outlined,
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.scan);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
