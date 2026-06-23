import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/config.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.instance.post(Config.loginUrl, {
      'email': email,
      'password': password,
    });

    final token = _extractToken(data);
    ApiClient.instance.setToken(token);
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

    final token = _extractToken(data);
    ApiClient.instance.setToken(token);
    return _asMap(data);
  }

  Future<Map<String, dynamic>?> me() async {
    final data = await ApiClient.instance.get(Config.meUrl, authenticated: true);
    return data == null ? null : _asMap(data);
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post(Config.logoutUrl, {}, authenticated: true);
    } finally {
      ApiClient.instance.clearToken();
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

  String? _extractToken(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final token = data['token'] ??
        data['accessToken'] ??
        data['access_token'] ??
        data['jwt'] ??
        (data['data'] is Map<String, dynamic> ? (data['data'] as Map<String, dynamic>)['token'] : null) ??
        (data['data'] is Map<String, dynamic> ? (data['data'] as Map<String, dynamic>)['accessToken'] : null);

    return token?.toString();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{};
  }
}
