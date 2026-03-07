import 'package:equatable/equatable.dart';

class DeviceLog extends Equatable {
  final String id;
  final String deviceId;
  final DateTime date;
  final int? usage;
  final String? notes;

  const DeviceLog({
    required this.id,
    required this.deviceId,
    required this.date,
    this.usage,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    deviceId,
    date,
    usage,
    notes,
  ];
}