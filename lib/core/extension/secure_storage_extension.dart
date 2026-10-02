import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageExtension {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'gym_role';

  Future<void> saveToken(String token, {String? role}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (role != null && role.trim().isNotEmpty) {
      await _storage.write(key: _roleKey, value: role.trim().toLowerCase());
    }
  }

  Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
