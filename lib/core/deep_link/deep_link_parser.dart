import 'package:nasyad/core/deep_link/deep_link_constants.dart';
import 'package:nasyad/core/deep_link/deep_link_target.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';

/// Parses canonical `nasyad://` URIs into typed [DeepLinkTarget] values.
abstract final class DeepLinkParser {
  static DeepLinkTarget? parse(Uri uri) {
    if (uri.scheme != DeepLinkConstants.scheme) {
      return null;
    }

    final location = _normalizedLocation(uri);
    if (location == null) {
      return null;
    }

    final path = Uri(path: location).path;
    final segments = path.split('/').where((segment) => segment.isNotEmpty);
    final parts = segments.toList(growable: false);
    final query = uri.queryParameters;

    if (parts.isEmpty) {
      return const DeepLinkHome();
    }

    return switch (parts) {
      ['devices'] => const DeepLinkDevices(),
      ['preferences'] => const DeepLinkPreferences(),
      ['preferences', 'transfer'] => const DeepLinkTransfer(),
      ['birthdays'] => const DeepLinkBirthdays(),
      ['birthdays', 'new'] => const DeepLinkBirthdayNew(),
      ['birthdays', final id, 'edit'] when id.isNotEmpty =>
        DeepLinkBirthdayEdit(id: id),
      ['device', 'new'] => DeepLinkDeviceNew(parentId: query['parentId']),
      ['device', final id] when id.isNotEmpty && id != 'new' =>
        DeepLinkDeviceView(id: id),
      ['device', final id, 'edit'] when id.isNotEmpty => DeepLinkDeviceEdit(
        id: id,
      ),
      ['device', final id, 'log'] when id.isNotEmpty => DeepLinkDeviceLog(
        id: id,
        kind: _parseLogKind(query['kind']),
      ),
      _ => null,
    };
  }

  static String? _normalizedLocation(Uri uri) {
    final host = uri.host;
    final path = uri.path;

    if (host.isNotEmpty) {
      if (path.isEmpty || path == '/') {
        return '/$host';
      }
      return '/$host$path';
    }

    if (path.isEmpty || path == '/') {
      return '/';
    }

    return path.startsWith('/') ? path : '/$path';
  }

  static DeviceLogKind? _parseLogKind(String? value) {
    return switch (value) {
      'usage' => DeviceLogKind.usageUpdate,
      'maintenance' => DeviceLogKind.maintenanceDone,
      _ => null,
    };
  }
}
