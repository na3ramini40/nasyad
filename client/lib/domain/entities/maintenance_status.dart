enum MaintenanceStatus {
  upToDate(0),
  soon(1),
  due(2);

  const MaintenanceStatus(this.severity);

  final int severity;

  static MaintenanceStatus worst(Iterable<MaintenanceStatus> statuses) {
    var current = MaintenanceStatus.upToDate;
    for (final status in statuses) {
      if (status.severity > current.severity) {
        current = status;
      }
    }
    return current;
  }
}
