import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _values;

  const AppLocalizations._(this.locale, this._values);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const delegate = _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) async {
    final raw = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return AppLocalizations._(
      locale,
      decoded.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  String text(String key, {Map<String, Object?> values = const {}}) {
    var result = _values[key] ?? key;
    values.forEach((name, value) {
      result = result.replaceAll('{$name}', value?.toString() ?? '');
    });
    return result;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const {'ar', 'en'}.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppTranslation on BuildContext {
  String tr(String key, {Map<String, Object?> values = const {}}) =>
      AppLocalizations.of(this).text(key, values: values);
}
