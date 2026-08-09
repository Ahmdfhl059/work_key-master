import 'package:flutter/material.dart';

class ProfileStrings {
  final bool ar;
  const ProfileStrings._(this.ar);
  factory ProfileStrings.of(BuildContext context) =>
      ProfileStrings._(Localizations.localeOf(context).languageCode == 'ar');
  String get title => ar ? 'ملفي الشخصي' : 'My profile';
  String get edit => ar ? 'تعديل الملف' : 'Edit profile';
  String get about => ar ? 'نبذة عني' : 'About me';
  String get experience => ar ? 'الخبرات' : 'Experience';
  String get education => ar ? 'التعليم' : 'Education';
  String get skills => ar ? 'المهارات' : 'Skills';
  String get preferences => ar ? 'التفضيلات المهنية' : 'Career preferences';
  String get contact => ar ? 'معلومات التواصل' : 'Contact information';
  String get settings => ar ? 'الإعدادات' : 'Settings';
  String get language => ar ? 'اللغة' : 'Language';
  String get logout => ar ? 'تسجيل الخروج' : 'Log out';
  String get retry => ar ? 'إعادة المحاولة' : 'Try again';
  String get emptySummary => ar
      ? 'أضف نبذة مهنية لتعرّف الشركات بخبراتك وطموحاتك.'
      : 'Add a professional summary to introduce your experience and goals.';
}
