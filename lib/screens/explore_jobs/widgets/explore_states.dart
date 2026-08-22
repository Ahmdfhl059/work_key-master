import 'package:flutter/material.dart';
import 'package:work_key/localization/app_localizations.dart';
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
  Widget build(BuildContext context) => ResponsiveContent(
    maxWidth: 520,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.work_off_outlined, size: 62, color: context.appMuted),
          SizedBox(height: 16),
          DefaultText(
            text: 'explore.empty_title',
            style: TextStyle(
              color: context.appInk,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          DefaultText(
            text: 'explore.empty_body',
            style: TextStyle(color: context.appMuted),
          ),
        ],
      ),
    ),
  );
}

class ExploreErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ExploreErrorState({super.key, required this.onRetry});

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
            text: 'explore.load_error_title',
            style: TextStyle(
              color: context.appInk,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            context.tr('explore.load_error_body'),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted, height: 1.45),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(onRetry: onRetry),
        ],
      ),
    ),
  );
}
