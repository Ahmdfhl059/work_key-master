import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/shared preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(
        ThemeState(_decode(CacheHelper.getData(key: 'THEME_MODE')?.toString())),
      );

  Future<void> setMode(ThemeMode mode) async {
    await CacheHelper.saveData(key: 'THEME_MODE', value: mode.name);
    emit(ThemeState(mode));
  }

  Future<void> toggle(bool dark) =>
      setMode(dark ? ThemeMode.dark : ThemeMode.light);

  static ThemeMode _decode(String? value) => switch (value) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.light,
  };
}
