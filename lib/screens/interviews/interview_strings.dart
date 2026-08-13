import 'package:flutter/widgets.dart';

class InterviewStrings {
  final bool isArabic;
  const InterviewStrings(this.isArabic);

  factory InterviewStrings.of(BuildContext context) => InterviewStrings(
    Localizations.localeOf(context).languageCode.toLowerCase() == 'ar',
  );

  String get title => isArabic ? 'مقابلاتي' : 'My interviews';
  String get subtitle => isArabic
      ? 'تابع مواعيد المقابلات وتفاصيل الحضور'
      : 'Keep track of schedules and attendance details';
  String get emptyTitle =>
      isArabic ? 'لا توجد مقابلات بعد' : 'No interviews yet';
  String get emptyBody => isArabic
      ? 'ستظهر المقابلات المجدولة هنا عند إضافتها.'
      : 'Your scheduled interviews will appear here.';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Try again';
  String get viewDetails => isArabic ? 'عرض التفاصيل' : 'View details';
  String get confirm => isArabic ? 'تأكيد الحضور' : 'Confirm attendance';
  String get join => isArabic ? 'الانضمام للمقابلة' : 'Join interview';
  String get location => isArabic ? 'الموقع' : 'Location';
  String get meetingLink => isArabic ? 'رابط الاجتماع' : 'Meeting link';
  String get duration => isArabic ? 'المدة' : 'Duration';
  String get mode => isArabic ? 'نمط المقابلة' : 'Interview mode';
  String get confirmation =>
      isArabic ? 'تأكيد الحضور' : 'Attendance confirmation';
  String get application => isArabic ? 'طلب التوظيف' : 'Job application';
  String get detailsTitle => isArabic ? 'تفاصيل المقابلة' : 'Interview details';
  String get confirmedMessage => isArabic
      ? 'تم تأكيد حضورك بنجاح.'
      : 'Your attendance has been confirmed.';
  String get confirmQuestion => isArabic
      ? 'هل تريد تأكيد حضور هذه المقابلة؟'
      : 'Confirm that you will attend this interview?';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirmAction => isArabic ? 'تأكيد' : 'Confirm';
  String minutes(int count) => isArabic ? '$count دقيقة' : '$count minutes';
}
