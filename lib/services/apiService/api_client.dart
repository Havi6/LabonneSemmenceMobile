import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
  
  /// Callback pour rafraîchir la session en cas de 401
  Future<bool> Function()? onRefreshToken;
  
  /// Callback pour notifier d'une déconnexion forcée
  void Function()? onSessionExpired;

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

  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) {
    return _send('POST', url, body: body, authenticated: authenticated);
  }

  Future<dynamic> patch(
    String url,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) {
    return _send('PATCH', url, body: body, authenticated: authenticated);
  }

  Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) {
    return _send('PUT', url, body: body, authenticated: authenticated);
  }

  Future<dynamic> delete(String url, {bool authenticated = false}) async {
    return await _send('DELETE', url, authenticated: authenticated);
  }

  Future<dynamic> uploadFile(
    String url, {
    required Uint8List bytes,
    required String filename,
    String field = 'file',
    Map<String, String> fields = const {},
    bool authenticated = false,
  }) async {
    if (authenticated && !isAuthenticated) {
      throw const ApiException(
        'Votre session a expiré. Veuillez vous reconnecter.',
        401,
      );
    }
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Accept'] = 'application/json';
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: filename,
        contentType: _contentTypeFor(filename),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response, 'POST', url);
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

    if (authenticated && !isAuthenticated) {
      // Tentative de refresh automatique avant d'abandonner
      final refreshed = await _attemptSilentRefresh();
      if (!refreshed) {
        throw const ApiException(
          'Votre session a expiré. Veuillez vous reconnecter.',
          401,
        );
      }
    }

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final uri = Uri.parse(url);
    late final http.Response response;

    try {
      response = await _executeRequest(method, uri, headers, body);
    } catch (e) {
      if (e is http.ClientException) {
        throw const ApiException('Erreur de connexion réseau.');
      }
      rethrow;
    }

    // Gestion du 401 (Unauthorized) pour tenter un refresh silencieux
    if (response.statusCode == 401 &&
        authenticated &&
        !url.contains('/api/auth/refresh')) {
      final refreshed = await _attemptSilentRefresh();
      if (refreshed) {
        // Rejouer la requête avec le nouveau token
        headers['Authorization'] = 'Bearer $_accessToken';
        final retryResponse = await _executeRequest(method, uri, headers, body);
        return _processResponse(retryResponse, method, url);
      } else {
        _notifySessionExpired();
      }
    }

    return _processResponse(response, method, url);
  }

  Future<bool> _attemptSilentRefresh() async {
    if (onRefreshToken == null) return false;
    try {
      return await onRefreshToken!();
    } catch (_) {
      return false;
    }
  }

  void _notifySessionExpired() {
    if (onSessionExpired != null) {
      onSessionExpired!();
    }
  }

  Future<http.Response> _executeRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
      case 'PATCH':
        return http.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
      case 'PUT':
        return http.put(uri, headers: headers, body: jsonEncode(body ?? {}));
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw ApiException('Methode HTTP non supportee: $method');
    }
  }

  dynamic _processResponse(http.Response response, String method, String url) {
    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API Error ($method $url): ${response.statusCode} - ${response.body}');
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
      final message =
          decoded['message'] ??
          decoded['error'] ??
          decoded['detail'] ??
          decoded['msg'];
      if (message != null) {
        if (message is List) return message.join(', ');
        return message.toString();
      }
    }

    if (decoded is String && decoded.isNotEmpty) {
      // Si le serveur renvoie du texte brut (ex: erreur 500 HTML ou texte simple)
      if (decoded.contains('<!DOCTYPE html>') || decoded.contains('<html>')) {
        return 'Erreur interne du serveur (HTML).';
      }
      return decoded;
    }

    return 'Une erreur est survenue pendant la requête API.';
  }

  MediaType _contentTypeFor(String filename) {
    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    return switch (extension) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'gif' => MediaType('image', 'gif'),
      'mp3' => MediaType('audio', 'mpeg'),
      'wav' => MediaType('audio', 'wav'),
      'm4a' => MediaType('audio', 'mp4'),
      'aac' => MediaType('audio', 'aac'),
      _ => MediaType('application', 'octet-stream'),
    };
  }
}
