import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';

class ApplicationsStrings {
  final BuildContext context;
  const ApplicationsStrings._(this.context);
  factory ApplicationsStrings.of(BuildContext context) =>
      ApplicationsStrings._(context);
  String get title => context.tr('nav.applications');
  String get all => context.tr('applications.all');
  String get active => context.tr('applications.active');
  String get action => context.tr('applications.action');
  String get completed => context.tr('applications.completed');
  String get searchHint => context.tr('applications.search');
  String get viewDetails => context.tr('applications.view_details');
  String actionBanner(int count) =>
      context.tr('applications.action_banner', values: {'count': count});
  String empty(String group) => context.tr(switch (group) {
    'active' => 'applications.empty_active',
    'requires_action' => 'applications.empty_action',
    'completed' => 'applications.empty_completed',
    _ => 'applications.empty_all',
  });
}
