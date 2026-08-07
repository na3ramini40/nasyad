enum SyncEntityKind {
  device,
  deviceLog,
  birthday;

  String get storageValue => name;

  static SyncEntityKind fromStorage(String value) {
    return SyncEntityKind.values.firstWhere(
      (kind) => kind.storageValue == value,
      orElse: () => throw ArgumentError('Unknown SyncEntityKind: $value'),
    );
  }
}

enum SyncOperation {
  upsert,
  delete;

  String get storageValue => name;

  static SyncOperation fromStorage(String value) {
    return SyncOperation.values.firstWhere(
      (op) => op.storageValue == value,
      orElse: () => throw ArgumentError('Unknown SyncOperation: $value'),
    );
  }
}
