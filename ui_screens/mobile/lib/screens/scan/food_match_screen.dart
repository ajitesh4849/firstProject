import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/scan_result.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ux_states.dart';

class FoodMatchScreen extends StatefulWidget {
  const FoodMatchScreen({super.key, required this.args});

  final FoodMatchArgs args;

  @override
  State<FoodMatchScreen> createState() => _FoodMatchScreenState();
}

class _FoodMatchScreenState extends State<FoodMatchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _loading = false;
  bool _confirming = false;
  String? _error;
  List<FoodCandidate> _results = const [];

  @override
  void initState() {
    super.initState();
    _results = widget.args.initialCandidates;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
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
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), () => _match(trimmed));
  }

  Future<void> _match(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await foodApi.matchFoodCandidates(query);
      if (!mounted || _controller.text.trim() != query) return;
      setState(() {
        _results = results;
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
        _error = 'Could not match foods right now.';
        _loading = false;
      });
    }
  }

  Future<void> _pick(FoodCandidate candidate) async {
    if (_confirming) return;
    setState(() => _confirming = true);
    try {
      final food = await foodApi.confirmScan(
        scanId: widget.args.scanId,
        foodName: candidate.foodName,
        confidence: candidate.confidence,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.portion,
        arguments: food,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not confirm this dish')),
      );
    }
  }

  String _categoryLabel(String raw) {
    if (raw.isEmpty) return 'Food';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase().replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final showHint = query.length < 2 && !_loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What did you eat?'),
        actions: [
          TextButton(
            onPressed: _confirming
                ? null
                : () {
                    Navigator.pushNamed(context, AppRoutes.foodSearch);
                  },
            child: const Text('Search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Image.memory(
                        widget.args.imageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceMuted,
                          alignment: Alignment.center,
                          child: const Icon(Icons.restaurant_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Type the dish name. Matches use your food catalog — not AI vision yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: !_confirming,
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    onSubmitted: (value) {
                      _debounce?.cancel();
                      final trimmed = value.trim();
                      if (trimmed.length >= 2) _match(trimmed);
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g. paneer butter, dal, dosa…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.clear();
                                _onQueryChanged('');
                                _focus.requestFocus();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (_confirming)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            Expanded(
              child: _loading
                  ? const LoadingView(label: 'Matching catalog…')
                  : _error != null
                      ? ErrorState(
                          title: 'Match failed',
                          message: _error!,
                          onRetry: () => _match(query),
                        )
                      : showHint
                          ? const EmptyState(
                              title: 'Name your dish',
                              message:
                                  'Enter at least 2 letters. We’ll rank real catalog matches with a match score.',
                              icon: Icons.edit_note_rounded,
                            )
                          : _results.isEmpty
                              ? EmptyState(
                                  title: 'No catalog matches',
                                  message:
                                      'Nothing close to “$query”. Try a shorter name or open Search.',
                                  icon: Icons.search_off_rounded,
                                  actionLabel: 'Open food search',
                                  onAction: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.foodSearch,
                                    );
                                  },
                                )
                              : ListView.separated(
                                  padding: AppSpacing.page,
                                  itemCount: _results.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = _results[index];
                                    final pct = item.confidencePercent;
                                    return AppCard(
                                      onTap: _confirming
                                          ? null
                                          : () => _pick(item),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.foodName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _categoryLabel(item.category),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '$pct%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: pct >= 80
                                                      ? AppColors.success
                                                      : pct >= 55
                                                          ? AppColors.warning
                                                          : AppColors
                                                              .textSecondary,
                                                  fontWeight: FontWeight.w800,
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
