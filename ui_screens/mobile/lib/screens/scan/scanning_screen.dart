import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../models/ingredient_awareness.dart';
import '../../models/scan_image_args.dart';
import '../../models/scan_result.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../services/placeholder_image.dart';
import '../../utils/app_theme.dart';
import '../../widgets/ux_states.dart';

enum _ScanPhase { loading, error }

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key, this.imageArgs});

  final ScanImageArgs? imageArgs;

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  _ScanPhase _phase = _ScanPhase.loading;
  String _status = 'Preparing image…';
  String _errorMessage =
      'We could not identify this image. Try again with better lighting.';

  @override
  void initState() {
    super.initState();
    _runScan();
  }

  Future<void> _runScan() async {
    setState(() {
      _phase = _ScanPhase.loading;
      _status = 'Preparing image…';
    });

    final args = widget.imageArgs;
    if (args?.forceFailure == true) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _phase = _ScanPhase.error;
        _errorMessage = 'Scan failed. Please try again.';
      });
      return;
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _status = 'Saving scan…');

      final bytes = args?.bytes.isNotEmpty == true
          ? args!.bytes
          : PlaceholderImage.jpegBytes;
      final filename = args?.filename ?? 'meal.jpg';

      final scan = await foodApi.createScan(
        imageBytes: bytes,
        filename: filename,
      );
      if (!mounted) return;

      setState(() => _status = 'Opening matches…');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      final imageBytes = Uint8List.fromList(bytes);

      if (scan.needsUserPick || scan.food == null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.foodMatch,
          arguments: FoodMatchArgs(
            scanId: scan.scanId,
            imageBytes: imageBytes,
            filename: filename,
            initialCandidates: scan.candidates,
            identifierMode: scan.identifierMode,
          ),
        );
        return;
      }

      final awarenessJson = scan.food!.awareness;
      final food = FoodItem(
        name: scan.food!.name,
        confidence: scan.food!.confidence,
        scanId: scan.scanId,
        awareness: awarenessJson == null
            ? null
            : IngredientAwareness.fromJson(awarenessJson),
      );
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.foodResult,
        arguments: food,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _ScanPhase.error;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _ScanPhase.error;
        _errorMessage =
            'Unable to analyze this photo right now. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.imageArgs?.bytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyzing'),
        automaticallyImplyLeading: false,
        actions: [
          if (_phase == _ScanPhase.loading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: _phase == _ScanPhase.error
              ? ErrorState(
                  title: 'Couldn’t start scan',
                  message: _errorMessage,
                  onRetry: _runScan,
                  onSecondary: () => Navigator.pop(context),
                  secondaryLabel: 'Back to camera',
                )
              : Column(
                  children: [
                    if (preview != null && preview.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.memory(
                            Uint8List.fromList(preview),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const Spacer(),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 18),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Photo stays on this device for now. You’ll name the dish next.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}
