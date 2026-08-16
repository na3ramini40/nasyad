import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';

enum HomeReminderKind { device, birthday, tag }

enum HomeReminderUrgency { due, soon, upcoming }

class HomeReminder extends Equatable {
  const HomeReminder({
    required this.id,
    required this.kind,
    required this.title,
    required this.urgency,
    required this.sortKey,
    this.deviceId,
    this.birthdayId,
    this.tagId,
    this.deviceStatus,
    this.deviceProgress,
    this.daysUntilBirthday,
  });

  final String id;
  final HomeReminderKind kind;
  final String title;
  final HomeReminderUrgency urgency;
  final int sortKey;
  final String? deviceId;
  final String? birthdayId;
  final String? tagId;
  final MaintenanceStatus? deviceStatus;
  final double? deviceProgress;
  final int? daysUntilBirthday;

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    urgency,
    sortKey,
    deviceId,
    birthdayId,
    tagId,
    deviceStatus,
    deviceProgress,
    daysUntilBirthday,
  ];
}
