import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_navigator.dart';
import '../config/api_config.dart';
import '../routes/app_routes.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const _tokenKey = 'foodscan_access_token';

  final http.Client _http;
  String? _accessToken;
  bool _handlingUnauthorized = false;

  String? get accessToken => _accessToken;

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

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _http
        .get(_uri(path), headers: _headers(json: false))
        .timeout(ApiConfig.timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _http
        .post(
          _uri(path),
          headers: _headers(),
          body: jsonEncode(body ?? {}),
        )
        .timeout(ApiConfig.timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _http
        .put(
          _uri(path),
          headers: _headers(),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> postMultipart({
    required String path,
    required String fieldName,
    required List<int> bytes,
    required String filename,
    String contentType = 'image/jpeg',
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamed = await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
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

    if (response.statusCode == 401) {
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
            'Request failed (${response.statusCode})';
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
