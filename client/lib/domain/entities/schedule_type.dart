enum ScheduleType { calendarInterval, usageInterval, fixedDate }

extension ScheduleTypeX on ScheduleType {
  String get storageValue => name;

  static ScheduleType fromStorage(String value) {
    return ScheduleType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ScheduleType.calendarInterval,
    );
  }
}
