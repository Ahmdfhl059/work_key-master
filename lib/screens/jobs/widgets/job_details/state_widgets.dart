part of '../../job_details_screen.dart';

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appSoftBrand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: HomeColors.purple),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: DefaultText(
                text: title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    ),
  );
}

class _JobDetailsSkeleton extends StatelessWidget {
  const _JobDetailsSkeleton();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ResponsiveContent(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          Container(
            height: 230,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [colors.primaryContainer, colors.secondaryContainer],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 58, height: 58, radius: 18),
                SizedBox(height: 18),
                SkeletonBox(width: 250, height: 22, radius: 8),
                SizedBox(height: 10),
                SkeletonBox(width: 150, height: 13, radius: 6),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (_) => Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 175, height: 18, radius: 7),
                  SizedBox(height: 18),
                  SkeletonBox(width: double.infinity, height: 12),
                  SizedBox(height: 10),
                  SkeletonBox(width: double.infinity, height: 12),
                  SizedBox(height: 10),
                  SkeletonBox(width: 210, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobDetailsMessageState extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String bodyKey;
  final VoidCallback? onRetry;

  const _JobDetailsMessageState({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ResponsiveContent(
      maxWidth: 520,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 86),
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr(titleKey),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(bodyKey),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.5),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 22),
            Center(child: ModernRetryButton(onRetry: onRetry!)),
          ],
        ],
      ),
    );
  }
}
