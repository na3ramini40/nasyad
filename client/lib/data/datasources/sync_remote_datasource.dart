import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nasyad/core/config/api_config.dart';
import 'package:nasyad/data/datasources/sync_api_exception.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/data/models/device_tag_link_model.dart';
import 'package:nasyad/data/models/tag_model.dart';

/// HTTP adapter for syncable resources (devices, logs, birthdays, tags, links).
abstract class SyncRemoteDataSource {
  Future<List<DeviceModel>> listDevices({
    required String token,
    DateTime? updatedSince,
  });

  Future<DeviceModel> upsertDevice({
    required String token,
    required DeviceModel device,
  });

  Future<List<DeviceLogModel>> listDeviceLogs({
    required String token,
    DateTime? createdSince,
  });

  Future<DeviceLogModel> upsertDeviceLog({
    required String token,
    required DeviceLogModel log,
  });

  Future<List<BirthdayModel>> listBirthdays({
    required String token,
    DateTime? updatedSince,
  });

  Future<BirthdayModel> upsertBirthday({
    required String token,
    required BirthdayModel birthday,
  });

  Future<List<TagModel>> listTags({
    required String token,
    DateTime? updatedSince,
  });

  Future<TagModel> upsertTag({required String token, required TagModel tag});

  Future<void> deleteTag({required String token, required String id});

  Future<List<DeviceTagLinkModel>> listDeviceTagLinks({
    required String token,
    DateTime? createdSince,
  });

  Future<DeviceTagLinkModel> upsertDeviceTagLink({
    required String token,
    required DeviceTagLinkModel link,
  });

  Future<void> deleteDeviceTagLink({
    required String token,
    required String deviceId,
    required String tagId,
  });
}

class HttpSyncRemoteDataSource implements SyncRemoteDataSource {
  HttpSyncRemoteDataSource({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl;

  final http.Client _client;
  final String? _baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) {
    final Uri base;
    if (_baseUrl == null) {
      base = ApiConfig.uri(path);
    } else {
      final root = _baseUrl.endsWith('/')
          ? _baseUrl.substring(0, _baseUrl.length - 1)
          : _baseUrl;
      final normalized = path.startsWith('/') ? path : '/$path';
      base = Uri.parse('$root$normalized');
    }
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...query});
  }

  Map<String, String> _jsonHeaders(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Token $token',
  };

  @override
  Future<List<DeviceModel>> listDevices({
    required String token,
    DateTime? updatedSince,
  }) async {
    final query = <String, String>{
      if (updatedSince != null)
        'updated_since': updatedSince.toUtc().toIso8601String(),
    };
    final response = await _client.get(
      _uri('/api/devices/', query),
      headers: _jsonHeaders(token),
    );
    return _parseResults(response, (map) => DeviceModel.fromSyncJson(map));
  }

  @override
  Future<DeviceModel> upsertDevice({
    required String token,
    required DeviceModel device,
  }) async {
    final response = await _client.put(
      _uri('/api/devices/${device.id}/'),
      headers: _jsonHeaders(token),
      body: jsonEncode(device.toSyncJson()),
    );
    return DeviceModel.fromSyncJson(_expectMap(response));
  }

  @override
  Future<List<DeviceLogModel>> listDeviceLogs({
    required String token,
    DateTime? createdSince,
  }) async {
    final query = <String, String>{
      if (createdSince != null)
        'created_since': createdSince.toUtc().toIso8601String(),
    };
    final response = await _client.get(
      _uri('/api/devices/logs/', query),
      headers: _jsonHeaders(token),
    );
    return _parseResults(response, (map) => DeviceLogModel.fromSyncJson(map));
  }

  @override
  Future<DeviceLogModel> upsertDeviceLog({
    required String token,
    required DeviceLogModel log,
  }) async {
    final response = await _client.put(
      _uri('/api/devices/logs/${log.id}/'),
      headers: _jsonHeaders(token),
      body: jsonEncode(log.toSyncJson()),
    );
    return DeviceLogModel.fromSyncJson(_expectMap(response));
  }

  @override
  Future<List<BirthdayModel>> listBirthdays({
    required String token,
    DateTime? updatedSince,
  }) async {
    final query = <String, String>{
      if (updatedSince != null)
        'updated_since': updatedSince.toUtc().toIso8601String(),
    };
    final response = await _client.get(
      _uri('/api/birthdays/', query),
      headers: _jsonHeaders(token),
    );
    return _parseResults(response, (map) => BirthdayModel.fromSyncJson(map));
  }

  @override
  Future<BirthdayModel> upsertBirthday({
    required String token,
    required BirthdayModel birthday,
  }) async {
    final response = await _client.put(
      _uri('/api/birthdays/${birthday.id}/'),
      headers: _jsonHeaders(token),
      body: jsonEncode(birthday.toSyncJson()),
    );
    return BirthdayModel.fromSyncJson(_expectMap(response));
  }

  @override
  Future<List<TagModel>> listTags({
    required String token,
    DateTime? updatedSince,
  }) async {
    final query = <String, String>{
      if (updatedSince != null)
        'updated_since': updatedSince.toUtc().toIso8601String(),
    };
    final response = await _client.get(
      _uri('/api/devices/tags/', query),
      headers: _jsonHeaders(token),
    );
    return _parseResults(response, (map) => TagModel.fromSyncJson(map));
  }

  @override
  Future<TagModel> upsertTag({
    required String token,
    required TagModel tag,
  }) async {
    final response = await _client.put(
      _uri('/api/devices/tags/${tag.id}/'),
      headers: _jsonHeaders(token),
      body: jsonEncode(tag.toSyncJson()),
    );
    return TagModel.fromSyncJson(_expectMap(response));
  }

  @override
  Future<void> deleteTag({required String token, required String id}) async {
    final response = await _client.delete(
      _uri('/api/devices/tags/$id/'),
      headers: _jsonHeaders(token),
    );
    _expectEmptySuccess(response);
  }

  @override
  Future<List<DeviceTagLinkModel>> listDeviceTagLinks({
    required String token,
    DateTime? createdSince,
  }) async {
    final query = <String, String>{
      if (createdSince != null)
        'created_since': createdSince.toUtc().toIso8601String(),
    };
    final response = await _client.get(
      _uri('/api/devices/tag-links/', query),
      headers: _jsonHeaders(token),
    );
    return _parseResults(
      response,
      (map) => DeviceTagLinkModel.fromSyncJson(map),
    );
  }

  @override
  Future<DeviceTagLinkModel> upsertDeviceTagLink({
    required String token,
    required DeviceTagLinkModel link,
  }) async {
    final response = await _client.put(
      _uri('/api/devices/tag-links/${link.deviceId}/${link.tagId}/'),
      headers: _jsonHeaders(token),
      body: jsonEncode(link.toSyncJson()),
    );
    return DeviceTagLinkModel.fromSyncJson(_expectMap(response));
  }

  @override
  Future<void> deleteDeviceTagLink({
    required String token,
    required String deviceId,
    required String tagId,
  }) async {
    final response = await _client.delete(
      _uri('/api/devices/tag-links/$deviceId/$tagId/'),
      headers: _jsonHeaders(token),
    );
    _expectEmptySuccess(response);
  }

  List<T> _parseResults<T>(
    http.Response response,
    T Function(Map<String, dynamic>) map,
  ) {
    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFrom(response.statusCode, body);
    }
    final results = body['results'];
    if (results is! List) {
      throw const SyncApiException(message: 'Invalid list response');
    }
    return results
        .whereType<Map>()
        .map((e) => map(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> _expectMap(http.Response response) {
    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFrom(response.statusCode, body);
    }
    return body;
  }

  void _expectEmptySuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFrom(response.statusCode, _decodeBody(response.body));
    }
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

  SyncApiException _exceptionFrom(int statusCode, Map<String, dynamic> body) {
    final detail = body['detail'];
    final message = switch (detail) {
      String s => s,
      List list => list.map((e) => e.toString()).join(', '),
      _ => 'Request failed ($statusCode)',
    };
    return SyncApiException(message: message, statusCode: statusCode);
  }
}
