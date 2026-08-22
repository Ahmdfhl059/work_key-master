import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';

class ActivityStrings {
  final BuildContext context;
  const ActivityStrings._(this.context);
  factory ActivityStrings.of(BuildContext context) => ActivityStrings._(context);
  String get title => context.tr('activity.title');
  String get all => context.tr('activity.all');
  String get action => context.tr('activity.action_needed');
  String get today => context.tr('activity.today');
  String get week => context.tr('activity.this_week');
  String get search => context.tr('activity.search');
  String get schedule => context.tr('activity.upcoming_schedule');
  String get feed => context.tr('activity.recent');
  String get required => context.tr('activity.requires_action');
  String get markAll => context.tr('activity.mark_all_read');
  String banner(int count) =>
      context.tr('activity.action_banner', values: {'count': count});
  String empty(String group, bool searching) => context.tr(
    searching
        ? 'activity.empty_search'
        : group == 'requires_action'
        ? 'activity.empty_action'
        : group == 'today'
        ? 'activity.empty_today'
        : group == 'this_week'
        ? 'activity.empty_week'
        : 'activity.empty_all',
  );
}
