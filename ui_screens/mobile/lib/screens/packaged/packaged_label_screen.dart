import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../services/food_api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';

class PackagedLabelScreen extends StatefulWidget {
  const PackagedLabelScreen({super.key, this.barcodeHint});

  final String? barcodeHint;

  @override
  State<PackagedLabelScreen> createState() => _PackagedLabelScreenState();
}

class _PackagedLabelScreenState extends State<PackagedLabelScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;
  String? _error;
  Uint8List? _previewBytes;
  String _filename = 'ingredients.jpg';

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _previewBytes = bytes;
        _filename = file.name.isNotEmpty ? file.name : 'ingredients.jpg';
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not open the camera or gallery.');
    }
  }

  Future<void> _analyze() async {
    final bytes = _previewBytes;
    if (bytes == null || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final result = await foodApi.analyzePackagedLabel(
        imageBytes: bytes,
        filename: _filename,
        barcodeHint: widget.barcodeHint,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.packagedResult,
        arguments: result,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            'Could not analyze this label right now. Check Wi‑Fi and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingredients photo')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Barcode not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Fallback: photograph the ingredients list on the pack. We’ll read the label and run the same ingredient checks.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _previewBytes == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.document_scanner_outlined,
                                  size: 48,
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tip: fill the frame with the ingredients panel and keep text sharp.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_previewBytes!, fit: BoxFit.contain),
                            if (_busy)
                              Container(
                                color: Colors.black45,
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Reading ingredients…',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Analyze ingredients photo',
                isLoading: _busy,
                onPressed: _previewBytes == null || _busy ? null : _analyze,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
