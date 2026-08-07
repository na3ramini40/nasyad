import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:nasyad/core/config/api_config.dart';
import 'package:nasyad/data/datasources/auth_api_exception.dart';
import 'package:nasyad/data/models/user_profile_model.dart';
import 'package:nasyad/domain/entities/otp_request_result.dart';
import 'package:nasyad/domain/entities/user_profile.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client, String? baseUrl})
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

  Future<OtpRequestResult> requestOtp(String phone) {
    return _postOtp('/api/accounts/otp/request/', phone);
  }

  Future<OtpRequestResult> resendOtp(String phone) {
    return _postOtp('/api/accounts/otp/resend/', phone);
  }

  Future<OtpRequestResult> _postOtp(String path, String phone) async {
    final response = await _client.post(
      _uri(path),
      headers: _jsonHeaders(),
      body: jsonEncode({'phone': phone}),
    );
    final body = _decodeBody(response.body);
    if (response.statusCode == 200) {
      return OtpRequestResult(
        phone: body['phone'] as String? ?? phone,
        cooldownSeconds: body['cooldown_seconds'] as int? ?? 120,
        expiresInSeconds: body['expires_in_seconds'] as int? ?? 600,
      );
    }
    throw _exceptionFrom(response.statusCode, body);
  }

  Future<({String token, UserProfile user})> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _client.post(
      _uri('/api/accounts/otp/verify/'),
      headers: _jsonHeaders(),
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    final body = _decodeBody(response.body);
    if (response.statusCode == 200) {
      final token = body['token'] as String?;
      final userJson = body['user'] as Map<String, dynamic>?;
      if (token == null || token.isEmpty || userJson == null) {
        throw const AuthApiException(message: 'Invalid verify response');
      }
      return (
        token: token,
        user: UserProfileModel.fromJson(userJson).toEntity(),
      );
    }
    throw _exceptionFrom(response.statusCode, body);
  }

  Future<UserProfile> getProfile(String token) async {
    final response = await _client.get(
      _uri('/api/accounts/profile/'),
      headers: _jsonHeaders(token: token),
    );
    final body = _decodeBody(response.body);
    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(body).toEntity();
    }
    throw _exceptionFrom(response.statusCode, body);
  }

  Future<UserProfile> updateProfile({
    required String token,
    String? name,
    File? imageFile,
  }) async {
    if (imageFile != null) {
      final request = http.MultipartRequest(
        'PATCH',
        _uri('/api/accounts/profile/'),
      );
      request.headers['Authorization'] = 'Token $token';
      request.headers['Accept'] = 'application/json';
      if (name != null) {
        request.fields['name'] = name;
      }
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      final body = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(body).toEntity();
      }
      throw _exceptionFrom(response.statusCode, body);
    }

    final response = await _client.patch(
      _uri('/api/accounts/profile/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({if (name != null) 'name': name}),
    );
    final body = _decodeBody(response.body);
    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(body).toEntity();
    }
    throw _exceptionFrom(response.statusCode, body);
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      _uri('/api/accounts/logout/'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }
    final body = _decodeBody(response.body);
    throw _exceptionFrom(response.statusCode, body);
  }

  /// Upserts this install's FCM registration. Success returns the registration
  /// payload; callers typically discard it after a 200.
  Future<Map<String, dynamic>> upsertDeviceRegistration({
    required String token,
    required String deviceId,
    required String fcmToken,
  }) async {
    final response = await _client.put(
      _uri('/api/accounts/registrations/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'device_id': deviceId, 'fcm_token': fcmToken}),
    );
    final body = _decodeBody(response.body);
    if (response.statusCode == 200) {
      return body;
    }
    throw _exceptionFrom(response.statusCode, body);
  }

  Map<String, dynamic> _decodeBody(String raw) {
    if (raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'detail': raw};
    } catch (_) {
      return {'detail': raw};
    }
  }

  AuthApiException _exceptionFrom(int statusCode, Map<String, dynamic> body) {
    final detail = body['detail'];
    final message = switch (detail) {
      String s => s,
      List list => list.map((e) => e.toString()).join(', '),
      _ => _firstFieldError(body) ?? 'Request failed ($statusCode)',
    };
    final retry = body['retry_after_seconds'];
    final fieldErrors = <String, List<String>>{};
    for (final entry in body.entries) {
      if (entry.key == 'detail' || entry.key == 'retry_after_seconds') continue;
      final value = entry.value;
      if (value is List) {
        fieldErrors[entry.key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[entry.key] = [value];
      }
    }
    return AuthApiException(
      message: message,
      statusCode: statusCode,
      retryAfterSeconds: retry is int ? retry : null,
      fieldErrors: fieldErrors,
    );
  }

  String? _firstFieldError(Map<String, dynamic> body) {
    for (final entry in body.entries) {
      if (entry.key == 'detail' || entry.key == 'retry_after_seconds') continue;
      final value = entry.value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
