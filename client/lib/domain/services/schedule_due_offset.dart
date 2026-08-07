/// Computes a due date from a calendar interval offset.
DateTime dueDateFromInterval({
  required int intervalValue,
  required String intervalUnit,
  required DateTime from,
}) {
  return switch (intervalUnit) {
    'days' => from.add(Duration(days: intervalValue)),
    'weeks' => from.add(Duration(days: intervalValue * 7)),
    'months' => DateTime(
      from.year,
      from.month + intervalValue,
      from.day,
      from.hour,
      from.minute,
      from.second,
      from.millisecond,
      from.microsecond,
    ),
    _ => from,
  };
}
