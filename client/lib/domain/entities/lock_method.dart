/// Local-only lock method (`docs/domain/enums.md` — `lock_method`).
enum LockMethod {
  password,
  pin,
  biometric;

  String get storageValue => name;

  static LockMethod? fromStorage(String? value) {
    return switch (value) {
      'password' => LockMethod.password,
      'pin' => LockMethod.pin,
      'biometric' => LockMethod.biometric,
      _ => null,
    };
  }
}
