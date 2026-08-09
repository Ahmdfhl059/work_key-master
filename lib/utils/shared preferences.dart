import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);
    return await sharedPreferences.setDouble(key, value);
  }

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }
}

class LanguageCacheHelper {
  Future<void> cacheLanguageCode(String languageCode) async {
    await CacheHelper.saveData(key: "LOCALE", value: languageCode);
  }

  Future<String> getCachedLanguageCode() async {
    String? code = CacheHelper.getData(key: "LOCALE");
    return code ?? 'en';
  }
}

class ThemeCacheHelper {
  Future<void> cacheThemeIndex(int themeIndex) async {
    await CacheHelper.saveData(key: 'THEME_INDEX', value: themeIndex);
  }

  Future<int> getCachedThemeIndex() async {
    int? index = CacheHelper.getData(key: 'THEME_INDEX');
    return index ?? 0;
  }
}
