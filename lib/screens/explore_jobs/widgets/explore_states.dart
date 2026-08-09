import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ExploreLoadingState extends StatelessWidget {
  const ExploreLoadingState({super.key});

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

class ExploreEmptyState extends StatelessWidget {
  const ExploreEmptyState({super.key});

  @override
  Widget build(BuildContext context) => const ResponsiveContent(
    maxWidth: 520,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.work_off_outlined, size: 62, color: HomeColors.muted),
          SizedBox(height: 16),
          DefaultText(
            text: 'No jobs found',
            style: TextStyle(
              color: HomeColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          DefaultText(
            text: 'Try changing your search or filters.',
            style: TextStyle(color: HomeColors.muted),
          ),
        ],
      ),
    ),
  );
}

class ExploreErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ExploreErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => ResponsiveContent(
    maxWidth: 520,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 58,
            color: HomeColors.warning,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: message,
            style: const TextStyle(color: HomeColors.muted),
          ),
          const SizedBox(height: 18),
          DefaultButton(
            background: HomeColors.purple,
            text: 'Try again',
            uppercase: false,
            borderRadius: 14,
            fontSize: 14,
            onPress: onRetry,
          ),
        ],
      ),
    ),
  );
}
