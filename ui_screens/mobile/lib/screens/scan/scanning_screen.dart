import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/scan_image_args.dart';
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
      setState(() => _status = 'Identifying food…');

      final bytes = args?.bytes.isNotEmpty == true
          ? args!.bytes
          : PlaceholderImage.jpegBytes;
      final filename = args?.filename ?? 'meal.jpg';

      final food = await foodApi.createScan(
        imageBytes: bytes,
        filename: filename,
      );
      if (!mounted) return;

      setState(() => _status = 'Finalizing…');
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

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
                  title: 'Couldn’t detect food',
                  message: _errorMessage,
                  onRetry: _runScan,
                  onSecondary: () => Navigator.pop(context),
                  secondaryLabel: 'Back to camera',
                )
              : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      child: SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: preview == null || preview.isEmpty
                            ? Container(
                                color: AppColors.surfaceMuted,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_search_rounded,
                                  size: 56,
                                  color: AppColors.primary,
                                ),
                              )
                            : Image.memory(
                                Uint8List.fromList(preview),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(strokeWidth: 3.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This usually takes a few seconds',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}
