import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';

class ProfileStrings {
  final bool ar;
  final BuildContext context;
  const ProfileStrings._(this.context, this.ar);
  factory ProfileStrings.of(BuildContext context) => ProfileStrings._(
    context,
    Localizations.localeOf(context).languageCode == 'ar',
  );
  String get title => context.tr('profile.title');
  String get edit => context.tr('profile.edit');
  String get about => context.tr('profile.about');
  String get experience => context.tr('profile.experience');
  String get education => context.tr('profile.education');
  String get skills => context.tr('profile.skills');
  String get preferences => context.tr('profile.preferences');
  String get contact => context.tr('profile.contact');
  String get settings => context.tr('settings.title');
  String get language => context.tr('settings.language');
  String get logout => context.tr('auth.logout');
  String get retry => context.tr('common.retry');
  String get emptySummary => context.tr('profile.empty_summary');
}
