enum DeviceLogKind { usageUpdate, maintenanceDone }

extension DeviceLogKindX on DeviceLogKind {
  String get storageValue => name;

  static DeviceLogKind fromStorage(String value) {
    return DeviceLogKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => DeviceLogKind.maintenanceDone,
    );
  }
}
