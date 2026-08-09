import 'package:flutter/material.dart';
import 'package:work_key/data/models/activity_response_model.dart';
import 'package:work_key/screens/applications/widgets/application_details_screen.dart';
import 'package:work_key/screens/home_screen/home_navigation.dart';
import 'package:work_key/shared/components/components.dart';

abstract final class ActivityNavigation {
  static Future<void> open(BuildContext context, ActivityItem item) async {
    final action = item.action;
    if (action == null) return;
    if (action.type.key == 'view_application' && action.target.id != null) {
      await navigateTo(context, ApplicationDetailsScreen(applicationId: action.target.id!));
      return;
    }
    HomeNavigation.openTarget(context, action.target.type, id: action.target.id?.toString());
  }
}
