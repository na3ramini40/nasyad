enum DeviceStatus {
  active,
  archived,
  deleted,
}

extension DeviceStatusX on DeviceStatus {
  String get storageValue => name;

  static DeviceStatus fromStorage(String value) {
    return DeviceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DeviceStatus.active,
    );
  }
}
