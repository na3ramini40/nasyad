import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit({ThemeMode initialMode = ThemeMode.system})
    : super(initialMode);

  void setThemeMode(ThemeMode mode) {
    if (state == mode) return;
    emit(mode);
  }
}
