import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';

/// Typed in-app navigation target parsed from a [Uri].
sealed class DeepLinkTarget extends Equatable {
  const DeepLinkTarget();

  @override
  List<Object?> get props => [];
}

final class DeepLinkHome extends DeepLinkTarget {
  const DeepLinkHome();
}

final class DeepLinkDevices extends DeepLinkTarget {
  const DeepLinkDevices();
}

final class DeepLinkPreferences extends DeepLinkTarget {
  const DeepLinkPreferences();
}

final class DeepLinkTransfer extends DeepLinkTarget {
  const DeepLinkTransfer();
}

final class DeepLinkBirthdays extends DeepLinkTarget {
  const DeepLinkBirthdays();
}

final class DeepLinkBirthdayNew extends DeepLinkTarget {
  const DeepLinkBirthdayNew();
}

final class DeepLinkBirthdayEdit extends DeepLinkTarget {
  const DeepLinkBirthdayEdit({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class DeepLinkDeviceNew extends DeepLinkTarget {
  const DeepLinkDeviceNew({this.parentId});

  final String? parentId;

  @override
  List<Object?> get props => [parentId];
}

final class DeepLinkDeviceView extends DeepLinkTarget {
  const DeepLinkDeviceView({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class DeepLinkDeviceEdit extends DeepLinkTarget {
  const DeepLinkDeviceEdit({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class DeepLinkDeviceLog extends DeepLinkTarget {
  const DeepLinkDeviceLog({required this.id, this.kind});

  final String id;
  final DeviceLogKind? kind;

  @override
  List<Object?> get props => [id, kind];
}
