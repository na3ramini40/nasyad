import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({Locale? initialLocale})
      : super(initialLocale ?? AppLocales.english);

  bool get isPersian => state.languageCode == 'fa';

  void setLocale(Locale locale) {
    if (state == locale) return;
    if (!AppLocales.isSupported(locale)) return;
    emit(Locale(locale.languageCode));
  }

  void toggle() {
    setLocale(isPersian ? AppLocales.english : AppLocales.persian);
  }
}

abstract final class AppLocales {
  static const english = Locale('en');
  static const persian = Locale('fa');

  static const supported = <Locale>[english, persian];

  static bool isSupported(Locale locale) {
    return supported.any((item) => item.languageCode == locale.languageCode);
  }

  static Locale resolve(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale != null && isSupported(deviceLocale)) {
      return Locale(deviceLocale.languageCode);
    }
    return english;
  }
}
