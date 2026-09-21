import 'dart:convert';
import 'dart:io';

import 'package:gymora_fitness_management/config/env_config.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';

import 'package:gymora_fitness_management/core/error/app_exception.dart';
import 'package:gymora_fitness_management/core/service/logger_service.dart';
import 'package:gymora_fitness_management/core/service/secure_storage_service.dart';
import 'package:gymora_fitness_management/core/service/session_manager.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final LoggingService _logger = LoggingService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Reads from .env via EnvConfig — no hardcoded URLs.
  String _currentBaseUrl;

  ApiHelper({String? baseUrl}) : _currentBaseUrl = baseUrl ?? EnvConfig.baseUrl;

  /// Override at runtime if needed (e.g. a micro-service on a different host).
  void setBaseUrl(String baseUrl) {
    _currentBaseUrl = baseUrl;
  }

  // ── HTTP verbs (unchanged) ─────────────────────────────────

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('GET', endpoint, headers: headers);
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('POST', endpoint, body: body, headers: headers);
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('PUT', endpoint, body: body, headers: headers);
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return _request<T>('PATCH', endpoint, body: body, headers: headers);
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _request<T>('DELETE', endpoint, body: body, headers: headers);
  }

  // ── Core request handler ───────────────────────────────────

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    // Ensure exactly one '/' between base URL and endpoint
    final base = _currentBaseUrl.endsWith('/')
        ? _currentBaseUrl
        : '$_currentBaseUrl/';
    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = Uri.parse('$base$path');
    http.Response response;
    final sanitizedBody = body != null
        ? _sanitizeRequestBody(jsonEncode(body))
        : null;

    final defaultHeaders = await _defaultHeaders(headers);
    _logger.logApi(
      '=== REQUEST START ===\n'
      'Method: $method\nURL: $url\n'
      'Headers: ${_sanitizeHeaders(defaultHeaders)}\n'
      'Body: $sanitizedBody',
    );

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: defaultHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: defaultHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: defaultHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: defaultHeaders,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            url,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        default:
          throw BadRequestException('Invalid HTTP method');
      }

      _logger.logApi(
        '=== RESPONSE ===\n'
        'Status Code: ${response.statusCode}\n'
        'Body: ${_sanitizeResponseBody(response.body)}',
      );

      return _handleResponse<T>(response);
    } on SocketException catch (e, s) {
      _logger.error(
        'NETWORK',
        'No Internet Connection',
        error: e,
        stackTrace: s,
      );
      return ApiResponse.error('No Internet Connection');
    } on AppException catch (e, s) {
      _logger.error('API_EXCEPTION', e.message, error: e, stackTrace: s);
      return ApiResponse.error(e.message);
    } catch (e, s) {
      _logger.error(
        'UNEXPECTED',
        'Unexpected error: $e',
        error: e,
        stackTrace: s,
      );
      return ApiResponse.error('Something went wrong. Please try again later.');
    }
  }

  // ── Headers ────────────────────────────────────────────────

  Future<Map<String, String>> _defaultHeaders(
    Map<String, String>? customHeaders,
  ) async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?customHeaders,
    };
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    const sensitiveHeaders = [
      'authorization',
      'x-api-key',
      'cookie',
      'set-cookie',
    ];
    for (final key in sanitized.keys.toList()) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '***REDACTED***';
      }
    }
    return sanitized;
  }

  String _sanitizeRequestBody(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(data);
        const sensitiveFields = ['password', 'token', 'secret', 'key', 'otp'];
        for (final field in sensitiveFields) {
          if (sanitized.containsKey(field)) sanitized[field] = '***REDACTED***';
        }
        return jsonEncode(sanitized);
      }
    } catch (_) {}
    return body;
  }

  String _sanitizeResponseBody(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(data);
        const sensitiveFields = ['token', 'secret', 'key', 'password'];
        for (final field in sensitiveFields) {
          if (sanitized.containsKey(field)) sanitized[field] = '***REDACTED***';
        }
        return jsonEncode(sanitized);
      }
    } catch (_) {}
    return body.length > 1000
        ? '${body.substring(0, 1000)}...[TRUNCATED]'
        : body;
  }

  // ── Helpers ────────────────────────────────────────────────

  /// Returns true if the raw body looks like an HTML page
  /// (common when hitting the wrong URL or a web-server 404 page).
  bool _isHtmlResponse(String body) {
    final trimmed = body.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype') || trimmed.startsWith('<html');
  }

  // ── Response handling ──────────────────────────────────────

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final statusCode = response.statusCode;
    dynamic body;

    // ── Guard: if the response is HTML, short-circuit immediately ──
    if (_isHtmlResponse(response.body)) {
      _logger.error(
        'API_RESPONSE',
        'Received HTML instead of JSON (status $statusCode). '
            'Check BASE_URL in your .env file.',
      );
      return ApiResponse.error(
        'Server returned an unexpected response. '
        'Please check the API URL configuration.',
        statusCode: statusCode,
      );
    }

    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = response.body;
    }

    // Session-expiry detection
    if (body is Map<String, dynamic>) {
      final bodyStatus = body['status'];
      final bodyMessage = body['message']?.toString() ?? '';
      final isUnauthorized =
          bodyStatus == false &&
          bodyMessage.toLowerCase().contains('unauthorized');
      if (isUnauthorized || statusCode == 401) {
        SessionManager.instance.notifyExpired(
          'Session expired. Please login again.',
        );
        return ApiResponse.error(
          bodyMessage.isNotEmpty
              ? bodyMessage
              : 'Unauthorized or token expired',
        );
      }
    } else if (statusCode == 401) {
      SessionManager.instance.notifyExpired(
        'Session expired. Please login again.',
      );
    }

    // ══════════════════════════════════════════════════════════════════
    // FIX: Check BOTH 'status' and 'success' keys.
    // The API returns {"success": false, ...} but the old code only
    // checked body['status']. This caused 409 errors to fall through
    // to the switch-default, losing the real error message.
    // ══════════════════════════════════════════════════════════════════
    if (body is Map<String, dynamic> &&
        (body['status'] == false || body['success'] == false)) {
      return ApiResponse.error(
        body['message']?.toString() ?? 'Request was rejected',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(body as T, statusCode: statusCode);
    }

    String message = 'Something went wrong';
    if (body is Map<String, dynamic>) {
      message = body['message']?.toString() ?? message;
    } else if (body is String) {
      // Safety net: never show raw HTML or very long strings to the user
      message = body.trimLeft().startsWith('<')
          ? 'Server returned an unexpected response. Please check the API URL.'
          : (body.length > 200 ? '${body.substring(0, 200)}...' : body);
    }

    switch (statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 500:
        throw ServerException(message);
      default:
        // ════════════════════════════════════════════════════════════
        // FIX: Use the extracted `message` instead of a generic string.
        // Old code: 'Error occurred with StatusCode: $statusCode'
        // ════════════════════════════════════════════════════════════
        throw FetchDataException(message);
    }
  }
}
