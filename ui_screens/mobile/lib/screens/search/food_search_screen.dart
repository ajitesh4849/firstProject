import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/food_search_item.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ux_states.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  String _lastQuery = '';
  List<FoodSearchItem> _results = const [];
  FoodSearchItem? _compareA;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _search(initial);
      });
    } else {
      _focus.requestFocus();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
        _lastQuery = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), () {
      _search(trimmed);
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = query;
    });
    try {
      final results = await foodApi.searchFoods(query);
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || _lastQuery != query) return;
      setState(() {
        _error = 'Search failed. Try again.';
        _loading = false;
      });
    }
  }

  void _openNutrition(FoodSearchItem item) {
    Navigator.pushNamed(
      context,
      AppRoutes.nutrition,
      arguments: item.toServing(100),
    );
  }

  void _toggleCompare(FoodSearchItem item) {
    if (_compareA == null) {
      setState(() => _compareA = item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected ${item.name}. Pick a second food.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_compareA!.name == item.name) {
      setState(() => _compareA = null);
      return;
    }
    final a = _compareA!;
    setState(() => _compareA = null);
    Navigator.pushNamed(
      context,
      AppRoutes.foodCompare,
      arguments: (a: a, b: item),
    );
  }

  String _categoryLabel(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'Food';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final showEmptyPrompt = query.length < 2 && !_loading;
    final showNoResults =
        !_loading && _error == null && query.length >= 2 && _results.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search foods'),
        actions: [
          if (_compareA != null)
            TextButton(
              onPressed: () => setState(() => _compareA = null),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textInputAction: TextInputAction.search,
                onChanged: _onQueryChanged,
                onSubmitted: (value) {
                  _debounce?.cancel();
                  final trimmed = value.trim();
                  if (trimmed.length >= 2) _search(trimmed);
                },
                decoration: InputDecoration(
                  hintText: 'Try paneer, dal, roti…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            _controller.clear();
                            _onQueryChanged('');
                            _focus.requestFocus();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            if (_compareA != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: AppCard(
                  elevated: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.compare_arrows_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Comparing: ${_compareA!.name}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const LoadingView(label: 'Searching…')
                  : _error != null
                      ? ErrorState(
                          title: 'Search failed',
                          message: _error!,
                          onRetry: () => _search(_lastQuery),
                        )
                      : showEmptyPrompt
                          ? const EmptyState(
                              title: 'Find a food',
                              message:
                                  'Type at least 2 letters. Tap a result to log it, or use Compare for two foods.',
                              icon: Icons.manage_search_rounded,
                            )
                          : showNoResults
                              ? EmptyState(
                                  title: 'No matches',
                                  message:
                                      'Nothing found for “$query”. Try a shorter name.',
                                  icon: Icons.search_off_rounded,
                                )
                              : ListView.separated(
                                  padding: AppSpacing.page,
                                  itemCount: _results.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = _results[index];
                                    final selected =
                                        _compareA?.name == item.name;
                                    return AppCard(
                                      onTap: () => _openNutrition(item),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${_categoryLabel(item.category)} · ${item.caloriesPer100g} kcal/100g',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'P ${item.proteinPer100g} · C ${item.carbsPer100g} · F ${item.fatPer100g}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .primaryDark,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: selected
                                                ? 'Deselect'
                                                : 'Compare',
                                            onPressed: () =>
                                                _toggleCompare(item),
                                            icon: Icon(
                                              selected
                                                  ? Icons.check_circle_rounded
                                                  : Icons.compare_arrows_rounded,
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }
}
