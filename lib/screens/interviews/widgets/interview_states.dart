import 'package:flutter/material.dart';

import '../../../shared/components/components.dart';
import '../../../utils/constants.dart';
import '../interview_strings.dart';

class InterviewsLoadingState extends StatelessWidget {
  const InterviewsLoadingState({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      4,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: _InterviewSkeleton(),
      ),
    ),
  );
}

class _InterviewSkeleton extends StatelessWidget {
  const _InterviewSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.appDivider),
    ),
    child: const Column(
      children: [
        Row(
          children: [
            SkeletonBox(width: 52, height: 52, radius: 26),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 190, height: 15),
                  SizedBox(height: 8),
                  SkeletonBox(width: 115, height: 10),
                ],
              ),
            ),
            SkeletonBox(width: 72, height: 27, radius: 14),
          ],
        ),
        SizedBox(height: 16),
        SkeletonBox(width: double.infinity, height: 44, radius: 14),
        SizedBox(height: 13),
        Row(
          children: [
            SkeletonBox(width: 88, height: 27, radius: 9),
            SizedBox(width: 7),
            SkeletonBox(width: 102, height: 27, radius: 9),
          ],
        ),
      ],
    ),
  );
}

class InterviewsEmptyState extends StatelessWidget {
  const InterviewsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = InterviewStrings.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: context.appSoftBrand,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 42,
              color: HomeColors.purple,
            ),
          ),
          const SizedBox(height: 17),
          DefaultText(
            text: strings.emptyTitle,
            style: TextStyle(
              color: context.appInk,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          DefaultText(
            text: strings.emptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appMuted,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class InterviewsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const InterviewsErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final strings = InterviewStrings.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 60,
            color: HomeColors.warning,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: 'interviews.load_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted, height: 1.45),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(text: strings.retry, onRetry: onRetry),
        ],
      ),
    );
  }
}
