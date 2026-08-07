import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class ScheduleTemplate extends Equatable {
  const ScheduleTemplate({
    required this.id,
    required this.labelEn,
    required this.labelFa,
    required this.scheduleType,
    required this.intervalValue,
    required this.intervalUnit,
  });

  final String id;
  final String labelEn;
  final String labelFa;
  final ScheduleType scheduleType;
  final int intervalValue;
  final String intervalUnit;

  String labelFor(String languageCode) {
    return languageCode == 'fa' ? labelFa : labelEn;
  }

  bool matchesSchedule({
    required ScheduleType? scheduleType,
    required String? intervalUnit,
    required String intervalValueText,
  }) {
    return this.scheduleType == scheduleType &&
        this.intervalUnit == intervalUnit &&
        intervalValueText.trim() == '$intervalValue';
  }

  @override
  List<Object?> get props => [
    id,
    labelEn,
    labelFa,
    scheduleType,
    intervalValue,
    intervalUnit,
  ];
}
