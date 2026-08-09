import 'package:flutter/material.dart';

class ActivityStrings {
  final bool ar;
  const ActivityStrings._(this.ar);
  factory ActivityStrings.of(BuildContext context) => ActivityStrings._(Localizations.localeOf(context).languageCode == 'ar');
  String get title => ar ? 'نشاطي' : 'Activity';
  String get all => ar ? 'الكل' : 'All';
  String get action => ar ? 'يحتاج إجراء' : 'Action needed';
  String get today => ar ? 'اليوم' : 'Today';
  String get week => ar ? 'هذا الأسبوع' : 'This week';
  String get search => ar ? 'ابحث في نشاطك' : 'Search activity';
  String get schedule => ar ? 'الجدول القادم' : 'Upcoming schedule';
  String get feed => ar ? 'أنشطة أخرى' : 'Recent activity';
  String get required => ar ? 'يتطلب إجراء' : 'Requires action';
  String get markAll => ar ? 'تحديد الكل كمقروء' : 'Mark all as read';
  String banner(int count) => ar ? 'لديك $count أنشطة تحتاج إجراء' : '$count activities need your attention';
  String empty(String group, bool searching) => searching ? (ar ? 'لم نجد أنشطة تطابق البحث' : 'No activity matches your search') : ar ? (group == 'requires_action' ? 'لا توجد أنشطة تحتاج إجراء حاليًا' : group == 'today' ? 'لا توجد أنشطة لليوم' : group == 'this_week' ? 'لا توجد أنشطة لهذا الأسبوع' : 'لا توجد أنشطة حتى الآن') : (group == 'requires_action' ? 'No activities need action' : group == 'today' ? 'No activity today' : group == 'this_week' ? 'No activity this week' : 'No activity yet');
}
