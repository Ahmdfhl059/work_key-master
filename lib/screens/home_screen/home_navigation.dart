import 'package:flutter/material.dart';
import 'package:work_key/data/models/cv_file_model.dart';
import 'package:work_key/screens/interviews/interview_details_screen.dart';
import 'package:work_key/screens/interviews/interviews_screen.dart';
import 'package:work_key/screens/notifications/notifications_screen.dart';
import 'package:work_key/screens/profile/cv_review_screen.dart';
import 'package:work_key/screens/profile/profile_screen.dart';
import 'package:work_key/screens/tests/tests_screen.dart';
import 'package:work_key/screens/jobs/job_details_screen.dart';
import 'package:work_key/screens/applications/widgets/application_details_screen.dart';
import 'package:work_key/screens/applications/information_request_screen.dart';
import 'package:work_key/shared/components/components.dart';

abstract final class HomeNavigation {
  static void openTarget(
    BuildContext context,
    String type, {
    String? id,
    String? value,
  }) {
    final targetType = type.trim().toLowerCase();
    final route = value?.trim() ?? '';
    final routeSegments = Uri.tryParse(route)?.pathSegments ?? const <String>[];
    final routeId = routeSegments.isEmpty ? null : routeSegments.last;
    final effectiveId = id ?? routeId;
    if (targetType == 'notifications' || targetType == 'notification') {
      navigateTo(context, const NotificationsScreen());
      return;
    }
    if (targetType == 'profile_section' ||
        targetType == 'profile' ||
        targetType == 'profile_suggestions') {
      navigateTo(context, const ProfileScreen());
      return;
    }
    if (targetType == 'cv_review' || targetType == 'review_cv') {
      final cvId = int.tryParse(id ?? value ?? '');
      navigateTo(
        context,
        cvId == null
            ? const ProfileScreen()
            : CvReviewScreen(cvFile: CvFileModel(id: cvId)),
      );
      return;
    }
    if (targetType == 'interview' || targetType.contains('interview')) {
      final interviewId = int.tryParse(effectiveId ?? '');
      navigateTo(
        context,
        interviewId == null
            ? const InterviewsScreen()
            : InterviewDetailsScreen(interviewId: interviewId),
      );
      return;
    }
    if (targetType == 'test_assignment' ||
        targetType == 'test' ||
        targetType.contains('test')) {
      navigateTo(context, const TestsScreen());
      return;
    }
    if (targetType == 'information_request' ||
        targetType == 'submit_information' ||
        routeSegments.contains('information-requests')) {
      final requestId = int.tryParse(effectiveId ?? '');
      if (requestId != null) {
        navigateTo(
          context,
          InformationRequestScreen(informationRequestId: requestId),
        );
      }
      return;
    }
    if (targetType == 'application' ||
        targetType == 'job_application' ||
        targetType == 'application_status' ||
        targetType.contains('application') ||
        routeSegments.contains('applications')) {
      final applicationId = int.tryParse(effectiveId ?? '');
      if (applicationId != null) {
        navigateTo(
          context,
          ApplicationDetailsScreen(applicationId: applicationId),
        );
      }
      return;
    }
    if (targetType == 'job' ||
        targetType == 'job_posting' ||
        targetType.contains('job') ||
        routeSegments.contains('jobs')) {
      final jobId = int.tryParse(effectiveId ?? '');
      if (jobId != null) navigateTo(context, JobDetailsScreen(jobId: jobId));
      return;
    }
    // Unknown home actions are useful profile tasks; never open a blank page.
    navigateTo(context, const ProfileScreen());
  }
}
