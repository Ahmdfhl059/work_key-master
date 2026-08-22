import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ActivityLoadingState extends StatelessWidget {
  const ActivityLoadingState({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      4,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ),
  );
}

class ActivityEmptyState extends StatelessWidget {
  final String message;
  const ActivityEmptyState({super.key, required this.message});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 65),
    child: Column(
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: 58,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 13),
        DefaultText(
          text: message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.appInk,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class ActivityErrorState extends StatelessWidget {
  final VoidCallback retry;
  const ActivityErrorState({super.key, required this.retry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 65),
    child: Column(
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 55,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        DefaultText(
          text: 'activity.load_error',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.appInk),
        ),
        const SizedBox(height: 16),
        ModernRetryButton(onRetry: retry),
      ],
    ),
  );
}
