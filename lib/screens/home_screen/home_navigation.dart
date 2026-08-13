import 'package:flutter/material.dart';
import 'package:work_key/screens/interviews/interview_details_screen.dart';
import 'package:work_key/screens/interviews/interviews_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

abstract final class HomeNavigation {
  static const Map<String, String> _titles = {
    'test_assignment': 'Test details',
    'interview': 'Interview details',
    'information_request': 'Information request',
    'cv_review': 'CV review',
    'profile_suggestions': 'Profile suggestions',
    'profile_section': 'Edit profile',
  };

  static void openTarget(
    BuildContext context,
    String type, {
    String? id,
    String? value,
  }) {
    // Semantic values are routing data only and must never be exposed in UI.
    if (type == 'interview') {
      final interviewId = int.tryParse(id ?? '');
      navigateTo(
        context,
        interviewId == null
            ? const InterviewsScreen()
            : InterviewDetailsScreen(interviewId: interviewId),
      );
      return;
    }
    navigateTo(context, HomeTargetPage(title: _titles[type] ?? 'Details'));
  }
}

class HomeTargetPage extends StatelessWidget {
  final String title;
  const HomeTargetPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: HomeColors.canvas,
    appBar: AppBar(
      title: DefaultText(
        text: title,
        style: const TextStyle(
          color: HomeColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: ResponsiveContent(
      maxWidth: 680,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_rounded, color: HomeColors.brand, size: 64),
            const SizedBox(height: 16),
            DefaultText(
              text: title,
              style: const TextStyle(
                color: HomeColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const DefaultText(
              text: 'Your details are ready.',
              style: TextStyle(color: HomeColors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    ),
  );
}
