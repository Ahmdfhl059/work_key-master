import 'package:flutter/widgets.dart';
import '../../localization/app_localizations.dart';

class InterviewStrings {
  final BuildContext context;
  const InterviewStrings(this.context);

  factory InterviewStrings.of(BuildContext context) =>
      InterviewStrings(context);

  String get title => context.tr('interviews.title');
  String get subtitle => context.tr('interviews.subtitle');
  String get emptyTitle => context.tr('interviews.empty_title');
  String get emptyBody => context.tr('interviews.empty_body');
  String get retry => context.tr('common.retry');
  String get viewDetails => context.tr('common.view_details');
  String get confirm => context.tr('interviews.confirm_attendance');
  String get join => context.tr('interviews.join');
  String get location => context.tr('profile.location_details');
  String get meetingLink => context.tr('interviews.meeting_link');
  String get duration => context.tr('interviews.duration');
  String get mode => context.tr('interviews.mode');
  String get confirmation => context.tr('interviews.attendance_confirmation');
  String get application => context.tr('interviews.job_application');
  String get detailsTitle => context.tr('interviews.details');
  String get confirmedMessage => context.tr('interviews.confirmed_message');
  String get confirmQuestion => context.tr('interviews.confirm_question');
  String get cancel => context.tr('common.cancel');
  String get confirmAction => context.tr('interviews.confirm');
  String minutes(int count) =>
      context.tr('interviews.minutes', values: {'count': count});
}
