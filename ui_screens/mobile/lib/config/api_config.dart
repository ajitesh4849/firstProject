import 'dart:io';

/// Backend + marketing-site URLs.
///
/// Privacy / Terms open the **advertising (Next.js) website**, not the API.
///
/// Dev defaults mirror the API host on port **3000**:
/// - Android emulator → `http://10.0.2.2:3000`
/// - Desktop / iOS sim → `http://127.0.0.1:3000`
/// - Physical device with `API_BASE_URL=http://192.168.x.x:8080`
///   → legal site `http://192.168.x.x:3000`
///
/// Production:
/// ```
/// flutter run \
///   --dart-define=API_BASE_URL=https://api.yourdomain.com \
///   --dart-define=LEGAL_BASE_URL=https://yourdomain.com
/// ```
class ApiConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return _stripTrailingSlash(fromEnv);
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://127.0.0.1:8080';
  }

  /// Marketing website (privacy + terms live here).
  static String get legalBaseUrl {
    const fromEnv = String.fromEnvironment('LEGAL_BASE_URL');
    if (fromEnv.isNotEmpty) return _stripTrailingSlash(fromEnv);

    final api = Uri.tryParse(baseUrl);
    if (api != null && api.host.isNotEmpty && _isDevHost(api.host)) {
      return Uri(
        scheme: api.scheme.isEmpty ? 'http' : api.scheme,
        host: api.host,
        port: 3000,
      ).toString();
    }

    // Production builds should pass LEGAL_BASE_URL; fall back to marketing host.
    if (api != null &&
        api.host.isNotEmpty &&
        !api.host.startsWith('api.')) {
      return Uri(scheme: api.scheme, host: api.host).toString();
    }
    if (api != null && api.host.startsWith('api.')) {
      return Uri(
        scheme: api.scheme,
        host: api.host.substring(4),
      ).toString();
    }

    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }

  static String get privacyUrl => '$legalBaseUrl/privacy';
  static String get termsUrl => '$legalBaseUrl/terms';

  static bool _isDevHost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        host.startsWith('172.');
  }

  static String _stripTrailingSlash(String value) =>
      value.replaceAll(RegExp(r'/$'), '');

  static const Duration timeout = Duration(seconds: 25);
  static const Duration scanTimeout = Duration(seconds: 40);
  static const Duration connectTimeout = Duration(seconds: 8);
}
