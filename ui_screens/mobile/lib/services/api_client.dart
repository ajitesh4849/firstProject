import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_navigator.dart';
import '../config/api_config.dart';
import '../routes/app_routes.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? _createHttpClient();

  static const _tokenKey = 'foodscan_access_token';

  http.Client _http;
  String? _accessToken;
  bool _handlingUnauthorized = false;
  bool _resettingClient = false;

  String? get accessToken => _accessToken;

  /// Fresh HttpClient so dead keep-alive sockets (after Wi‑Fi drops) are discarded.
  static http.Client _createHttpClient() {
    final inner = HttpClient()
      ..connectionTimeout = ApiConfig.connectTimeout
      ..idleTimeout = const Duration(seconds: 5)
      ..autoUncompress = true;
    return IOClient(inner);
  }

  /// Call after network failures so the next request opens a new connection.
  void resetHttpClient() {
    if (_resettingClient) return;
    _resettingClient = true;
    try {
      _http.close();
    } catch (_) {
      // ignore close errors on already-broken clients
    }
    _http = _createHttpClient();
    _resettingClient = false;
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
  }

  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Future<void> clearSession() => setAccessToken(null);

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  bool _isTransientNetworkError(Object error) {
    // Never retry timeouts — that doubles wait (e.g. 40s + 40s) on slow vision calls.
    if (error is TimeoutException) return false;
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is http.ClientException) return true;
    final message = error.toString().toLowerCase();
    return message.contains('connection') ||
        message.contains('network') ||
        message.contains('socket') ||
        message.contains('broken pipe') ||
        message.contains('connection reset');
  }

  Future<T> _withNetworkRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (!_isTransientNetworkError(error)) rethrow;
      // Wi‑Fi often returns while the old keep-alive socket is still dead.
      resetHttpClient();
      return await action();
    }
  }

  Future<Map<String, dynamic>> getJson(String path) {
    return _withNetworkRetry(() async {
      final response = await _http
          .get(_uri(path), headers: _headers(json: false))
          .timeout(ApiConfig.timeout);
      return _decode(response);
    });
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _withNetworkRetry(() async {
      final response = await _http
          .post(
            _uri(path),
            headers: _headers(),
            body: jsonEncode(body ?? {}),
          )
          .timeout(ApiConfig.timeout);
      return _decode(response);
    });
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
  }) {
    return _withNetworkRetry(() async {
      final response = await _http
          .put(
            _uri(path),
            headers: _headers(),
            body: jsonEncode(body ?? {}),
          )
          .timeout(ApiConfig.timeout);
      return _decode(response);
    });
  }

  Future<Map<String, dynamic>> postMultipart({
    required String path,
    required String fieldName,
    required List<int> bytes,
    required String filename,
    String contentType = 'image/jpeg',
    Map<String, String>? fields,
  }) {
    return _withNetworkRetry(() async {
      final request = http.MultipartRequest('POST', _uri(path));
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamed = await _http.send(request).timeout(ApiConfig.scanTimeout);
      final response = await http.Response.fromStream(streamed)
          .timeout(ApiConfig.scanTimeout);
      return _decode(response);
    });
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body ?? <String, dynamic>{};
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleUnauthorized();
    }

    final details = body?['details'];
    String? detailMessage;
    if (details is Map) {
      detailMessage = details.values.map((value) => value.toString()).join(' ');
    }

    final message = detailMessage?.isNotEmpty == true
        ? detailMessage!
        : body?['message']?.toString() ??
            body?['detail']?.toString() ??
            (response.statusCode == 401 || response.statusCode == 403
                ? 'Please log in again'
                : 'Request failed (${response.statusCode})');
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      await clearSession();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final nav = appNavigatorKey.currentState;
        if (nav == null) return;
        nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      });
    } finally {
      _handlingUnauthorized = false;
    }
  }
}

/// App-wide API client instance.
final apiClient = ApiClient();
