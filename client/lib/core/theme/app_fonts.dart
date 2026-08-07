import 'package:flutter/material.dart';

abstract final class AppFonts {
  static const vazir = 'Vazir';

  static String? familyForLocale(Locale locale) {
    return locale.languageCode == 'fa' ? vazir : null;
  }
}
