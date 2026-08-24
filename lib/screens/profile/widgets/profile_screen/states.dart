part of '../../profile_screen.dart';

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: ResponsiveContent(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.only(top: 18),
        children: [
          Container(
            width: 180,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 17),
          Container(
            height: 225,
            decoration: BoxDecoration(
              color: context.appSoftBrand,
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (_) => Container(
              height: 135,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(21),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _ProfileError({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined, size: 58, color: context.appMuted),
            const SizedBox(height: 12),
            DefaultText(
              text: message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appInk),
            ),
            const SizedBox(height: 16),
            ModernRetryButton(onRetry: retry),
          ],
        ),
      ),
    ),
  );
}
