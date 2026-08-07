import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/home_reminder.dart';

/// Platform-agnostic plan for a single local notification.
class PlannedLocalReminder extends Equatable {
  const PlannedLocalReminder({
    required this.notificationId,
    required this.reminder,
    required this.scheduledAt,
    required this.repeatsDaily,
    required this.deepLinkUri,
  });

  final int notificationId;
  final HomeReminder reminder;
  final DateTime scheduledAt;
  final bool repeatsDaily;
  final String deepLinkUri;

  @override
  List<Object?> get props => [
    notificationId,
    reminder,
    scheduledAt,
    repeatsDaily,
    deepLinkUri,
  ];
}
