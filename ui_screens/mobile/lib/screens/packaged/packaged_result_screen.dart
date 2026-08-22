import 'package:flutter/material.dart';

import '../../models/packaged_food_analysis.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/food_intelligence_card.dart';
import '../../widgets/primary_button.dart';

class PackagedResultScreen extends StatefulWidget {
  const PackagedResultScreen({super.key, required this.analysis});

  final PackagedFoodAnalysis analysis;

  @override
  State<PackagedResultScreen> createState() => _PackagedResultScreenState();
}

class _PackagedResultScreenState extends State<PackagedResultScreen> {
  late PackagedFoodAnalysis _analysis;
  late final TextEditingController _brandController;
  bool _saving = false;
  String? _saveMessage;

  @override
  void initState() {
    super.initState();
    _analysis = widget.analysis;
    _brandController = TextEditingController(text: _analysis.brand?.trim() ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  bool get _brandMissing => _brandController.text.trim().isEmpty;

  Color _scoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'BETTER':
        return AppColors.success;
      case 'CAUTION':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _sourceLabel(String? source) {
    switch (source) {
      case 'SEED':
        return 'FoodScan catalog';
      case 'LABEL_PHOTO':
        return 'From ingredients photo';
      case 'OPEN_FOOD_FACTS':
        return 'Open Food Facts';
      default:
        return 'Product data';
    }
  }

  Future<void> _saveToCatalog() async {
    if (_saving || !_analysis.canSaveToCatalog) return;
    final brand = _brandController.text.trim();
    if (brand.isEmpty) {
      setState(() {
        _saveMessage = 'Please mention the brand name so we can reuse it next time.';
      });
      return;
    }
    setState(() {
      _saving = true;
      _saveMessage = null;
      _analysis = _analysis.copyWith(brand: brand);
    });
    try {
      final saved = await foodApi.savePackagedToCatalog(_analysis);
      if (!mounted) return;
      setState(() {
        _analysis = saved;
        _brandController.text = saved.brand?.trim() ?? brand;
        _saving = false;
        _saveMessage =
            'Saved with brand “${saved.brand ?? brand}”. Next barcode scan will find it faster.';
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveMessage = 'Could not save this product right now.';
      });
    }
  }

  /// Split label text into readable rows and normalize ALL-CAPS walls of text.
  List<String> _ingredientItems(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*,\s*'), ', ')
        .trim();
    if (cleaned.isEmpty) return const [];

    final parts = cleaned
        .split(RegExp(r',\s*(?![^()]*\))'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      // Fallback: split on semicolons / periods if no useful commas.
      final alt = cleaned
          .split(RegExp(r'[;•|]'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      return (alt.length > 1 ? alt : [cleaned])
          .map(_readableIngredient)
          .toList();
    }
    return parts.map(_readableIngredient).toList();
  }

  String _readableIngredient(String value) {
    final text = value.trim();
    if (text.isEmpty) return text;

    // Keep short codes like E110 as-is; soften long ALL-CAPS labels.
    final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final mostlyUpper =
        letters.length >= 8 && letters == letters.toUpperCase();
    if (!mostlyUpper) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      // Preserve tokens like (71%), E110, MSG.
      if (RegExp(r'^[A-Z]?\d').hasMatch(word) ||
          RegExp(r'^\(?\d').hasMatch(word) ||
          word.length <= 3) {
        return word;
      }
      final lower = word.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).join(' ');
  }

  Widget _legendChip(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _ingredientRow(
    BuildContext context,
    int index,
    PackagedIngredientMark item,
  ) {
    final Color accent;
    final Color soft;
    final String badge;
    if (item.isUnhealthy) {
      accent = AppColors.danger;
      soft = AppColors.dangerSoft;
      badge = 'Watch';
    } else if (item.isHealthier) {
      accent = AppColors.success;
      soft = const Color(0xFFD1FADF);
      badge = 'Prefer';
    } else {
      accent = AppColors.textSecondary;
      soft = AppColors.surfaceMuted;
      badge = '';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Text(
            '$index',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _readableIngredient(item.text),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (badge.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: soft,
                        borderRadius: BorderRadius.circular(AppRadii.full),
                      ),
                      child: Text(
                        badge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
              if (item.reason != null && item.reason!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.reason!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(_analysis.score);

    return Scaffold(
      appBar: AppBar(title: const Text('Packaged check')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                            _analysis.productName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Brand',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _brandController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: _brandMissing
                                  ? 'Mention the brand name (e.g. Parle, Amul)'
                                  : 'Brand name',
                              helperText: _brandMissing
                                  ? 'Brand was not detected — add it so future scans can reuse it.'
                                  : 'Edit if this looks wrong; saved with the product catalog.',
                              helperMaxLines: 2,
                              prefixIcon: const Icon(Icons.storefront_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadii.md),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Barcode ${_analysis.barcode}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _sourceLabel(_analysis.source),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadii.full),
                              border: Border.all(
                                color: scoreColor.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'Score: ${_analysis.score}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: scoreColor),
                            ),
                          ),
                          if (_analysis.energyKcalPer100g != null ||
                              _analysis.sugarPer100g != null ||
                              _analysis.saltPer100g != null ||
                              _analysis.proteinPer100g != null ||
                              _analysis.fibrePer100g != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              [
                                if (_analysis.energyKcalPer100g != null)
                                  '${_analysis.energyKcalPer100g!.round()} kcal/100g',
                                if (_analysis.proteinPer100g != null)
                                  'P ${_analysis.proteinPer100g!.toStringAsFixed(1)}g',
                                if (_analysis.carbsPer100g != null)
                                  'C ${_analysis.carbsPer100g!.toStringAsFixed(1)}g',
                                if (_analysis.fatPer100g != null)
                                  'F ${_analysis.fatPer100g!.toStringAsFixed(1)}g',
                                if (_analysis.fibrePer100g != null)
                                  'Fibre ${_analysis.fibrePer100g!.toStringAsFixed(1)}g',
                                if (_analysis.sugarPer100g != null)
                                  'Sugar ${_analysis.sugarPer100g!.toStringAsFixed(1)}g',
                                if (_analysis.saltPer100g != null)
                                  'Salt ${_analysis.saltPer100g!.toStringAsFixed(2)}g',
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_analysis.intelligence != null) ...[
                      const SizedBox(height: 16),
                      FoodIntelligenceCard(
                        intelligence: _analysis.intelligence!,
                      ),
                    ] else ...[
                    const SizedBox(height: 16),
                    Text(
                      'Flags (${_analysis.riskCount})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    if (_analysis.flags.isEmpty)
                      AppCard(
                        child: Text(
                          'No major rule-based concerns found for this product.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      ..._analysis.flags.map(
                        (flag) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: _severityColor(flag.severity),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        flag.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        flag.detail,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${flag.code} · ${flag.severity}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Healthier swaps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final swap in _analysis.healthierSwaps) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.eco_outlined,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    swap,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (swap != _analysis.healthierSwaps.last)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    ],
                    if ((_analysis.ingredients.isNotEmpty) ||
                        (_analysis.ingredientsText != null &&
                            _analysis.ingredientsText!.trim().isNotEmpty)) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Builder(
                        builder: (context) {
                          final items = _analysis.ingredients.isNotEmpty
                              ? _analysis.ingredients
                              : _ingredientItems(_analysis.ingredientsText!)
                                  .map(
                                    (text) => PackagedIngredientMark(
                                      text: text,
                                      tag: 'NEUTRAL',
                                    ),
                                  )
                                  .toList();
                          final watchCount =
                              items.where((i) => i.isUnhealthy).length;
                          final preferCount =
                              items.where((i) => i.isHealthier).length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '$watchCount to watch · $preferCount preferable'
                                '${items.length - watchCount - preferCount > 0 ? ' · ${items.length - watchCount - preferCount} neutral' : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Soft labels only — educational rules, not medical advice.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  _legendChip(
                                    context,
                                    color: AppColors.danger,
                                    label: 'Watch / limit',
                                  ),
                                  _legendChip(
                                    context,
                                    color: AppColors.success,
                                    label: 'Prefer',
                                  ),
                                  _legendChip(
                                    context,
                                    color: AppColors.textSecondary,
                                    label: 'Neutral',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              AppCard(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  14,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0; i < items.length; i++) ...[
                                      _ingredientRow(
                                        context,
                                        i + 1,
                                        items[i],
                                      ),
                                      if (i < items.length - 1)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Divider(height: 1),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      _analysis.disclaimer,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_analysis.canSaveToCatalog) ...[
                    PrimaryButton(
                      label: 'Add to FoodScan catalog',
                      icon: Icons.bookmark_add_outlined,
                      isLoading: _saving,
                      onPressed: _saving ? null : _saveToCatalog,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analysis.isFromLabelPhoto
                          ? 'Save after a label photo so the next barcode scan finds this product locally.'
                          : 'Optional: save this Open Food Facts product locally for faster scans next time.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_saveMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _saveMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _analysis.canSaveToCatalog
                                  ? AppColors.danger
                                  : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ] else if (_saveMessage != null) ...[
                    Text(
                      _saveMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  PrimaryButton(
                    label: 'Scan another package',
                    icon: Icons.qr_code_scanner_rounded,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.packagedBarcode,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Back to Scan',
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.scan,
                        (route) =>
                            route.settings.name == AppRoutes.home ||
                            route.isFirst,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
