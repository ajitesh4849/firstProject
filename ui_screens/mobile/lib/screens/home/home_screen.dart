import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/mock_data.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ux_states.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = MockDataService.todayMeals;
    final progress = MockDataService.dailyGoalKcal == 0
        ? 0.0
        : MockDataService.consumedKcal / MockDataService.dailyGoalKcal;

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      bottomNavigationBar: const MainBottomNav(current: MainTab.home),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${MockDataService.consumedKcal} / ${MockDataService.dailyGoalKcal} kcal',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Daily intake',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).clamp(0, 999).round()}% of goal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Meals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (meals.isEmpty)
                EmptyState(
                  title: 'No meals yet',
                  message: 'Scan your first meal to start tracking today.',
                  icon: Icons.restaurant_outlined,
                  actionLabel: 'Scan Food',
                  onAction: () {
                    Navigator.pushNamed(context, AppRoutes.scan);
                  },
                )
              else
                ...meals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${meal.calories} kcal',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Scan Food',
                icon: Icons.camera_alt_outlined,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.scan);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
