import 'package:equatable/equatable.dart';

class DeviceTagLink extends Equatable {
  const DeviceTagLink({required this.deviceId, required this.tagId});

  final String deviceId;
  final String tagId;

  @override
  List<Object?> get props => [deviceId, tagId];
}
