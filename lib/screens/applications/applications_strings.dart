import 'package:flutter/material.dart';

class ApplicationsStrings {
  final bool ar;
  const ApplicationsStrings._(this.ar);
  factory ApplicationsStrings.of(BuildContext context) => ApplicationsStrings._(Localizations.localeOf(context).languageCode == 'ar');
  String get title => ar ? 'طلباتي' : 'Applications';
  String get all => ar ? 'الكل' : 'All';
  String get active => ar ? 'قيد المتابعة' : 'Active';
  String get action => ar ? 'تحتاج إجراء' : 'Action needed';
  String get completed => ar ? 'منتهية' : 'Completed';
  String get searchHint => ar ? 'ابحث في طلباتك' : 'Search applications';
  String get viewDetails => ar ? 'عرض التفاصيل' : 'View details';
  String actionBanner(int count) => ar ? 'لديك $count طلبات تحتاج إجراء' : '$count applications need your attention';
  String empty(String group) => ar ? (group == 'active' ? 'لا توجد طلبات قيد المتابعة' : group == 'requires_action' ? 'لا توجد طلبات تحتاج إجراء حاليًا' : group == 'completed' ? 'لا توجد طلبات منتهية' : 'لم تتقدم إلى أي وظيفة بعد') : (group == 'active' ? 'No active applications' : group == 'requires_action' ? 'No applications need action' : group == 'completed' ? 'No completed applications' : 'You have not applied to any jobs yet');
}
