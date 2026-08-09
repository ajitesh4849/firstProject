import 'package:flutter/material.dart';

import '../../models/daily_summary.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/main_bottom_nav.dart';
import '../../widgets/ux_states.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  String? _error;
  List<DailySummary> _history = const [];
  double _weeklyAverage = 0;
  DateTime _selectedDay = DateTime.now();

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
      final result = await foodApi.fetchHistory();
      if (!mounted) return;
      setState(() {
        _history = result.days;
        _weeklyAverage = result.weeklyAverage;
        _selectedDay = _history.isNotEmpty
            ? (_history.last.date ?? DateTime.now())
            : DateTime.now();
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
        _error = 'Unable to load history right now.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxCalories = _history
        .map((e) => e.calories)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(current: MainTab.history),
      body: SafeArea(
        child: _loading
            ? const LoadingView(label: 'Loading history…')
            : _error != null
                ? ErrorState(
                    title: 'Couldn’t load History',
                    message: _error!,
                    onRetry: _load,
                  )
                : _history.isEmpty
                    ? const Center(
                        child: EmptyState(
                          title: 'No history yet',
                          message:
                              'Once you log meals, weekly calorie summaries will appear here.',
                          icon: Icons.insights_outlined,
                        ),
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
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'This week',
                                      style:
                                          Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 86,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _history.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 10),
                                        itemBuilder: (context, index) {
                                          final day = _history[index];
                                          final selected =
                                              day.date?.day == _selectedDay.day &&
                                                  day.date?.month ==
                                                      _selectedDay.month;
                                          return InkWell(
                                            borderRadius: BorderRadius.circular(
                                              AppRadii.md,
                                            ),
                                            onTap: () {
                                              if (day.date != null) {
                                                setState(
                                                  () => _selectedDay = day.date!,
                                                );
                                              }
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 180,
                                              ),
                                              width: 64,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? AppColors.primary
                                                    : AppColors.surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppRadii.md,
                                                ),
                                                border: Border.all(
                                                  color: selected
                                                      ? AppColors.primary
                                                      : AppColors.border,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    day.label,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: selected
                                                          ? Colors.white
                                                          : AppColors
                                                              .textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${day.date?.day ?? '-'}',
                                                    style: TextStyle(
                                                      color: selected
                                                          ? Colors.white70
                                                          : AppColors
                                                              .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const SectionHeader(title: 'Daily totals'),
                              const SizedBox(height: 12),
                              ..._history.map((day) {
                                final ratio = maxCalories == 0
                                    ? 0.0
                                    : day.calories / maxCalories;
                                final selected =
                                    day.date?.day == _selectedDay.day &&
                                        day.date?.month == _selectedDay.month;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                day.label,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: selected
                                                          ? AppColors
                                                              .primaryDark
                                                          : null,
                                                    ),
                                              ),
                                            ),
                                            Text(
                                              '${day.calories} kcal',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.primaryDark,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.full,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: ratio,
                                            minHeight: 8,
                                            backgroundColor: AppColors.border,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              AppCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      'Weekly average',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${_weeklyAverage.round()} kcal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ],
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
