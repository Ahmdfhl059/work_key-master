import 'package:flutter/material.dart';
import 'package:work_key/data/models/applications_response_model.dart';
import 'package:work_key/screens/home_screen/home_navigation.dart';

abstract final class ApplicationNavigation {
  static void openNextAction(BuildContext context, NextAction action) {
    final target = switch (action.type.key) {
      'complete_test' => 'test_assignment',
      'submit_information' => 'information_request',
      'confirm_interview' || 'view_interview' => 'interview',
      _ => '',
    };
    HomeNavigation.openTarget(
      context,
      target,
      id: action.resourceId?.toString(),
    );
  }
}
