import 'package:equatable/equatable.dart';

class DeviceTagLink extends Equatable {
  const DeviceTagLink({
    required this.deviceId,
    required this.tagId,
    required this.createdAt,
  });

  final String deviceId;
  final String tagId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [deviceId, tagId, createdAt];
}
