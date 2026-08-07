import 'package:flutter/material.dart';

import 'package:nasyad/domain/entities/device_category_preset.dart';
import 'package:nasyad/l10n/app_localizations.dart';

IconData categoryPresetIcon(DeviceCategoryPreset? preset) {
  return switch (preset ?? DeviceCategoryPreset.generic) {
    DeviceCategoryPreset.generic => Icons.devices_other_outlined,
    DeviceCategoryPreset.car => Icons.directions_car_outlined,
    DeviceCategoryPreset.hvac => Icons.ac_unit_outlined,
    DeviceCategoryPreset.appliance => Icons.kitchen_outlined,
    DeviceCategoryPreset.electronics => Icons.computer_outlined,
    DeviceCategoryPreset.plumbing => Icons.plumbing_outlined,
  };
}

String categoryPresetLabel(
  AppLocalizations l10n,
  DeviceCategoryPreset? preset,
) {
  return switch (preset ?? DeviceCategoryPreset.generic) {
    DeviceCategoryPreset.generic => l10n.categoryGeneric,
    DeviceCategoryPreset.car => l10n.categoryCar,
    DeviceCategoryPreset.hvac => l10n.categoryHvac,
    DeviceCategoryPreset.appliance => l10n.categoryAppliance,
    DeviceCategoryPreset.electronics => l10n.categoryElectronics,
    DeviceCategoryPreset.plumbing => l10n.categoryPlumbing,
  };
}

List<DeviceCategoryPreset> get selectableCategoryPresets =>
    DeviceCategoryPreset.values;
