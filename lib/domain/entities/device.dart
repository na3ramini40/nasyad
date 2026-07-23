import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/device_status.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DeviceStatus status;
  final int currentUsage;
  final int usageAtLastMaintenance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Device({
    required this.id,
    required this.name,
    this.description,
    this.status = DeviceStatus.active,
    this.currentUsage = 0,
    this.usageAtLastMaintenance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Device copyWith({
    String? id,
    String? name,
    String? description,
    DeviceStatus? status,
    int? currentUsage,
    int? usageAtLastMaintenance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      currentUsage: currentUsage ?? this.currentUsage,
      usageAtLastMaintenance:
          usageAtLastMaintenance ?? this.usageAtLastMaintenance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        currentUsage,
        usageAtLastMaintenance,
        createdAt,
        updatedAt,
      ];
}
