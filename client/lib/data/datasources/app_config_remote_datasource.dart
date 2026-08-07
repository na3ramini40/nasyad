import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nasyad/core/config/api_config.dart';
import 'package:nasyad/domain/entities/app_config_snapshot.dart';

/// Fetches evaluated feature flags from `GET /api/app_config/`.
abstract class AppConfigRemoteDataSource {
  Future<AppConfigSnapshot> fetch({String? token});
}

class HttpAppConfigRemoteDataSource implements AppConfigRemoteDataSource {
  HttpAppConfigRemoteDataSource({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl;

  final http.Client _client;
  final String? _baseUrl;

  Uri _uri(String path) {
    if (_baseUrl == null) return ApiConfig.uri(path);
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized');
  }

  Map<String, String> _jsonHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
    };
  }

  @override
  Future<AppConfigSnapshot> fetch({String? token}) async {
    final response = await _client.get(
      _uri('/api/app_config/'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw AppConfigRemoteException(
        'app_config fetch failed (${response.statusCode})',
      );
    }
    return parseBody(response.body);
  }

  /// Parses wire JSON; ignores unknown top-level fields and non-bool feature
  /// values. Exposed for unit tests.
  static AppConfigSnapshot parseBody(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const AppConfigRemoteException('Invalid app_config body');
    }
    final map = Map<String, dynamic>.from(decoded);
    final featuresRaw = map['features'];
    final features = <String, bool>{};
    if (featuresRaw is Map) {
      for (final entry in featuresRaw.entries) {
        final key = entry.key;
        if (key is! String) continue;
        final value = entry.value;
        if (value is bool) {
          features[key] = value;
        }
      }
    }
    DateTime? updatedAt;
    final updatedRaw = map['updated_at'];
    if (updatedRaw is String && updatedRaw.isNotEmpty) {
      updatedAt = DateTime.tryParse(updatedRaw)?.toUtc();
    }
    return AppConfigSnapshot(
      features: Map.unmodifiable(features),
      updatedAt: updatedAt,
    );
  }
}

class AppConfigRemoteException implements Exception {
  const AppConfigRemoteException(this.message);

  final String message;

  @override
  String toString() => 'AppConfigRemoteException: $message';
}
