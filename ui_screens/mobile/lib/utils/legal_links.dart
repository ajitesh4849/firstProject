import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';

Future<void> openLegalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $url')),
    );
  }
}

Future<void> openPrivacyPolicy(BuildContext context) =>
    openLegalUrl(context, ApiConfig.privacyUrl);

Future<void> openTermsOfUse(BuildContext context) =>
    openLegalUrl(context, ApiConfig.termsUrl);
