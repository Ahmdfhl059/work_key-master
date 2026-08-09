import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/theme_cubit/theme_state.dart';

import '../../shared/theme/app_theme.dart';
import '../../utils/shared preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()){
    getCurrentThemeEvent();
  }

  Future<void> getCurrentThemeEvent() async {
    final themeIndex = await ThemeCacheHelper().getCachedThemeIndex();
    final theme = AppTheme.values.firstWhere((appTheme) {
      return appTheme.index == themeIndex;
    });
    print(theme);
    print(themeIndex);
    emit(
      LoadedThemeState(
        themeData: appThemeData[theme]!,
        isOn: theme == AppTheme.blueDark,
      ),
    );
  }

  Future<void> themeChangedEvent(AppTheme theme) async {
    final themeIndex = theme.index;
    await ThemeCacheHelper().cacheThemeIndex(themeIndex);
    emit(
      LoadedThemeState(
        themeData: appThemeData[theme]!,
        isOn: theme == AppTheme.blueDark,
      ),
    );
  }

  void toggleSwitch(bool value) {
    final theme = value ? AppTheme.blueDark : AppTheme.blueLight;
    ThemeCacheHelper().cacheThemeIndex(theme.index);
    emit(LoadedThemeState(isOn: value, themeData: appThemeData[theme]!));
  }
}
