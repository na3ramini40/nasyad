enum DeviceCategoryPreset {
  generic,
  car,
  hvac,
  appliance,
  electronics,
  plumbing,
}

extension DeviceCategoryPresetX on DeviceCategoryPreset {
  String get storageValue => name;

  static DeviceCategoryPreset? fromStorage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DeviceCategoryPreset.values.firstWhere(
      (preset) => preset.name == value,
      orElse: () => DeviceCategoryPreset.generic,
    );
  }
}
