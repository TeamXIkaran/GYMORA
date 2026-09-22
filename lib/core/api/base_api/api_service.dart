import 'package:gymora_fitness_management/core/api/base_api/api_helper.dart';
import 'package:gymora_fitness_management/core/api/base_api/api_response.dart';

/// Static convenience wrapper around [ApiHelper].
///
/// Services call `ApiService.get(...)` / `.post(...)` etc.
/// On success the raw JSON body (`Map<String, dynamic>`) is returned.
/// On failure an [Exception] is thrown with the error message.
class ApiService {
  static final ApiHelper _api = ApiHelper();

  ApiService._(); // prevent instantiation

  // ── GET ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final ApiResponse res = await _api.get(endpoint, headers: headers);
    return _unwrap(res);
  }

  // ── POST ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final ApiResponse res = await _api.post(endpoint, body, headers: headers);
    return _unwrap(res);
  }

  // ── PUT ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final ApiResponse res = await _api.put(endpoint, body, headers: headers);
    return _unwrap(res);
  }

  // ── PATCH ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final ApiResponse res = await _api.patch(endpoint, body, headers: headers);
    return _unwrap(res);
  }

  // ── DELETE ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final ApiResponse res = await _api.delete(
      endpoint,
      body: body,
      headers: headers,
    );
    return _unwrap(res);
  }

  // ── Helper ──────────────────────────────────────────────────

  static Map<String, dynamic> _unwrap(ApiResponse res) {
    if (res.success && res.data != null) {
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      // Wrap non-map responses so callers always get a Map
      return {'data': res.data};
    }
    throw Exception(res.message ?? 'Something went wrong');
  }
}
