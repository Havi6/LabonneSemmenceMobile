import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.instance.post(Config.loginUrl, {
      'email': email,
      'password': password,
    });

    await _storeSession(data);
    return _asMap(data);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.instance.post(Config.registerUrl, {
      'name': name,
      'email': email,
      'password': password,
    });

    await _storeSession(data);
    return _asMap(data);
  }

  /// Restaure une session uniquement si le refresh token sauvegardé est encore valide.
  Future<bool> restoreSession() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final data = await ApiClient.instance
          .post(Config.refreshUrl, {'refreshToken': refreshToken})
          .timeout(const Duration(seconds: 10));
      final accessToken = _extractAccessToken(data);
      if (accessToken == null || accessToken.isEmpty) {
        await _clearSession();
        return false;
      }

      ApiClient.instance.setToken(accessToken);
      final rotatedRefreshToken = _extractRefreshToken(data);
      if (rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty) {
        await _storage.write(key: _refreshTokenKey, value: rotatedRefreshToken);
      }
      return true;
    } catch (_) {
      await _clearSession();
      return false;
    }
  }

  Future<Map<String, dynamic>?> me() async {
    final data = await ApiClient.instance.get(
      Config.meUrl,
      authenticated: true,
    );
    return data == null ? null : _asMap(data);
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post(Config.logoutUrl, {}, authenticated: true);
    } finally {
      await _clearSession();
    }
  }

  Future<void> heartbeat() async {
    await ApiClient.instance.post(Config.heartbeatUrl, {}, authenticated: true);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.instance.patch(Config.passwordUrl, {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }, authenticated: true);
  }

  Future<void> _storeSession(dynamic data) async {
    ApiClient.instance.setToken(_extractAccessToken(data));

    final refreshToken = _extractRefreshToken(data);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } else {
      await _storage.delete(key: _refreshTokenKey);
    }
  }

  Future<void> _clearSession() async {
    ApiClient.instance.clearToken();
    await _storage.delete(key: _refreshTokenKey);
  }

  String? _extractAccessToken(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final nestedData = data['data'];
    final tokens =
        data['tokens'] ??
        (nestedData is Map<String, dynamic> ? nestedData['tokens'] : null);
    final token =
        data['token'] ??
        data['accessToken'] ??
        data['access_token'] ??
        data['jwt'] ??
        (nestedData is Map<String, dynamic>
            ? nestedData['token'] ??
                  nestedData['accessToken'] ??
                  nestedData['access_token'] ??
                  nestedData['jwt']
            : null) ??
        (tokens is Map<String, dynamic>
            ? tokens['token'] ?? tokens['accessToken'] ?? tokens['access_token']
            : null);

    return token?.toString();
  }

  String? _extractRefreshToken(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final nestedData = data['data'];
    final tokens =
        data['tokens'] ??
        (nestedData is Map<String, dynamic> ? nestedData['tokens'] : null);
    final token =
        data['refreshToken'] ??
        data['refresh_token'] ??
        (nestedData is Map<String, dynamic>
            ? nestedData['refreshToken'] ?? nestedData['refresh_token']
            : null) ??
        (tokens is Map<String, dynamic>
            ? tokens['refreshToken'] ?? tokens['refresh_token']
            : null);

    return token?.toString();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{};
  }
}
