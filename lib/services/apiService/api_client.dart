import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static String? _accessToken;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  void setToken(String? token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  Future<dynamic> get(String url, {bool authenticated = false}) {
    return _send('GET', url, authenticated: authenticated);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body, {bool authenticated = false}) {
    return _send('POST', url, body: body, authenticated: authenticated);
  }

  Future<dynamic> patch(String url, Map<String, dynamic> body, {bool authenticated = false}) {
    return _send('PATCH', url, body: body, authenticated: authenticated);
  }

  Future<dynamic> put(String url, Map<String, dynamic> body, {bool authenticated = false}) {
    return _send('PUT', url, body: body, authenticated: authenticated);
  }

  Future<void> delete(String url, {bool authenticated = false}) async {
    await _send('DELETE', url, authenticated: authenticated);
  }

  Future<dynamic> _send(
    String method,
    String url, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final uri = Uri.parse(url);
    late final http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: jsonEncode(body ?? {}));
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw ApiException('Methode HTTP non supportee: $method');
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractError(decoded), response.statusCode);
    }

    return decoded;
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractError(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
      if (message != null) {
        return message.toString();
      }
    }

    return 'Une erreur est survenue pendant la requete API.';
  }
}
