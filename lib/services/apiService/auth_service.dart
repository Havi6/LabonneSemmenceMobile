import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';

class AuthService {
  AuthService._() {
    ApiClient.instance.onRefreshToken = restoreSession;
    ApiClient.instance.onSessionExpired = () {
      sessionExpiredNotifier.value = true;
    };
  }

  static final AuthService instance = AuthService._();

  static const _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<bool>? _refreshTask;

  /// Notifie quand la session est définitivement perdue (ex: refresh token expiré)
  final ValueNotifier<bool> sessionExpiredNotifier = ValueNotifier(false);

  /// Notifie quand le rôle de l'utilisateur change
  final ValueNotifier<String?> userRoleNotifier = ValueNotifier(null);

  bool get isAdmin => userRoleNotifier.value == 'admin';

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
      'username': name,
      'email': email,
      'password': password,
      'role': 'user',
    });

    await _storeSession(data);
    return _asMap(data);
  }

  /// Restaure une session uniquement si le refresh token sauvegardé est encore valide.
  Future<bool> restoreSession() async {
    if (_refreshTask != null) return _refreshTask!;
    return _refreshTask = _doRestoreSession();
  }

  Future<bool> _doRestoreSession() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final data = await ApiClient.instance
          .post(Config.refreshUrl, {'refreshToken': refreshToken})
          .timeout(const Duration(seconds: 10));
      final accessToken = _extractAccessToken(data);
      if (accessToken == null || accessToken.isEmpty) {
        await _clearSession();
        return false;
      }

      ApiClient.instance.setToken(accessToken);
      
      // On récupère les infos complètes de l'utilisateur (dont le rôle)
      // Cela permet de garantir que l'interface (Drawer) sera à jour.
      try {
        await me();
      } catch (e) {
        debugPrint('Erreur lors de la récupération du profil après refresh: $e');
      }

      final rotatedRefreshToken = _extractRefreshToken(data);
      if (rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty) {
        await _storage.write(key: _refreshTokenKey, value: rotatedRefreshToken);
      }
      return true;
    } catch (_) {
      await _clearSession();
      return false;
    } finally {
      _refreshTask = null;
    }
  }

  Future<Map<String, dynamic>?> me() async {
    final data = await ApiClient.instance.get(
      Config.meUrl,
      authenticated: true,
    );
    final map = data == null ? null : _asMap(data);
    if (map != null) {
      final userData = map['user'] ?? map['data'] ?? map;
      if (userData is Map<String, dynamic>) {
        userRoleNotifier.value = userData['role']?.toString();
      }
    }
    return map;
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

  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    final data = await ApiClient.instance.patch(
      Config.meUrl,
      {'name': name},
      authenticated: true,
    );
    return _asMap(data);
  }

  Future<void> _storeSession(dynamic data) async {
    ApiClient.instance.setToken(_extractAccessToken(data));

    if (data is Map<String, dynamic>) {
      final userData = data['user'] ?? data['data'] ?? data;
      if (userData is Map<String, dynamic>) {
        userRoleNotifier.value = userData['role']?.toString();
      }
    }

    final refreshToken = _extractRefreshToken(data);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } else {
      await _storage.delete(key: _refreshTokenKey);
    }
  }

  Future<void> _clearSession() async {
    ApiClient.instance.clearToken();
    userRoleNotifier.value = null;
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
