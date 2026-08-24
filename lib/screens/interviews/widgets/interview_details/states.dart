part of '../../interview_details_screen.dart';

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();
  @override
  Widget build(BuildContext context) => const ResponsiveContent(
    maxWidth: 760,
    child: Padding(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: 185, radius: 27),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 96, radius: 21),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 240, radius: 21),
        ],
      ),
    ),
  );
}

class _DetailsError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DetailsError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: ResponsiveContent(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: HomeColors.warning,
            size: 58,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: 'interviews.details_load_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(onRetry: onRetry),
        ],
      ),
    ),
  );
}
