import 'package:nasyad/core/deep_link/deep_link_target.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';

/// Maps typed [DeepLinkTarget] values to [go_router] location strings.
abstract final class DeepLinkMapper {
  static String? toLocation(DeepLinkTarget target) {
    return switch (target) {
      DeepLinkHome() => '/',
      DeepLinkDevices() => '/devices',
      DeepLinkPreferences() => '/preferences',
      DeepLinkTransfer() => '/preferences/transfer',
      DeepLinkBirthdays() => '/birthdays',
      DeepLinkBirthdayNew() => '/birthdays/new',
      DeepLinkBirthdayEdit(:final id) => '/birthdays/$id/edit',
      DeepLinkDeviceNew(:final parentId) => _deviceNewLocation(parentId),
      DeepLinkDeviceView(:final id) => '/device/$id',
      DeepLinkDeviceEdit(:final id) => '/device/$id/edit',
      DeepLinkDeviceLog(:final id, :final kind) => _deviceLogLocation(id, kind),
    };
  }

  static String _deviceNewLocation(String? parentId) {
    if (parentId == null || parentId.isEmpty) {
      return '/device/new';
    }
    return Uri(
      path: '/device/new',
      queryParameters: {'parentId': parentId},
    ).toString();
  }

  static String _deviceLogLocation(String id, DeviceLogKind? kind) {
    final kindParam = switch (kind) {
      DeviceLogKind.usageUpdate => 'usage',
      DeviceLogKind.maintenanceDone => 'maintenance',
      null => null,
    };
    if (kindParam == null) {
      return '/device/$id/log';
    }
    return Uri(
      path: '/device/$id/log',
      queryParameters: {'kind': kindParam},
    ).toString();
  }
}
