import 'package:flutter/material.dart';
import 'package:work_key/screens/explore_jobs/explore_jobs_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ApplicationsLoadingState extends StatelessWidget {
  const ApplicationsLoadingState({super.key});
  @override
  Widget build(BuildContext context) => ResponsiveContent(
    child: Column(
      children: List.generate(
        4,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: JobCardSkeleton(),
        ),
      ),
    ),
  );
}

class ApplicationsEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onExplore;
  const ApplicationsEmptyState({
    super.key,
    required this.message,
    this.onExplore,
  });
  @override
  Widget build(BuildContext context) => ResponsiveContent(
    maxWidth: 520,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: context.appMuted, size: 64),
          const SizedBox(height: 14),
          DefaultText(
            text: message,
            style: TextStyle(
              color: context.appInk,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          DefaultButton(
            background: HomeColors.purple,
            text: 'Explore jobs',
            uppercase: false,
            borderRadius: 14,
            fontSize: 14,
            onPress:
                onExplore ??
                () => navigateTo(context, const ExploreJobsScreen()),
          ),
        ],
      ),
    ),
  );
}

class ApplicationsErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const ApplicationsErrorState({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) => ResponsiveContent(
    maxWidth: 520,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: HomeColors.warning,
            size: 62,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: 'applications.load_error',
            style: TextStyle(color: context.appMuted),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(onRetry: onRetry),
        ],
      ),
    ),
  );
}
