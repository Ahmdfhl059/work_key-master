part of '../../cv_review_screen.dart';

class _PrimaryAction extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool acting;
  final VoidCallback onPressed;

  const _PrimaryAction({
    required this.review,
    required this.acting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final action = _localizedKey(review['next_action']);
    if (action == 'review_suggestions') {
      final pending = _pendingSuggestionIds(review).length;
      return Column(
        children: [
          DefaultText(
            text: context.tr(
              'cv.pending_decisions',
              values: {'count': pending},
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          DefaultButton(
            background: HomeColors.purple,
            text: acting
                ? context.tr('cv.completing_review')
                : context.tr('cv.keep_remaining_continue'),
            uppercase: false,
            height: 54,
            borderRadius: 16,
            fontSize: 14,
            onPress: acting ? () {} : onPressed,
          ),
        ],
      );
    }
    final labelKey = switch (action) {
      'generate_suggestions' => 'cv.action_compare',
      'confirm' => 'cv.action_confirm',
      _ => 'cv.action_refresh',
    };
    final enabled =
        isCvActionAllowed(review, action) &&
        (action != 'confirm' ||
            (review['can_confirm'] == true && isCvReviewComplete(review)));
    return DefaultButton(
      background: HomeColors.purple,
      text: acting ? context.tr('common.please_wait') : context.tr(labelKey),
      uppercase: false,
      height: 54,
      borderRadius: 16,
      fontSize: 14,
      onPress: acting || !enabled ? () {} : onPressed,
    );
  }
}

class _WorkflowActionCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool acting;
  final VoidCallback onPressed;

  const _WorkflowActionCard({
    required this.review,
    required this.acting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.next_step'),
    icon: Icons.route_rounded,
    child: Column(
      children: [
        Text(
          _localizedLabel(
            review['next_action'],
            context.tr('cv.action_refresh'),
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 15),
        _PrimaryAction(review: review, acting: acting, onPressed: onPressed),
      ],
    ),
  );
}

class _WhiteCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _WhiteCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.surfaceContainer,
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .22),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: HomeColors.purple, size: 20),
            const SizedBox(width: 8),
            DefaultText(
              text: title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        child,
      ],
    ),
  );
}

class _ReviewLoading extends StatelessWidget {
  const _ReviewLoading();

  @override
  Widget build(BuildContext context) => const ResponsiveContent(
    maxWidth: 760,
    child: Padding(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: 110, radius: 24),
          SizedBox(height: 15),
          SkeletonBox(width: double.infinity, height: 320, radius: 20),
        ],
      ),
    ),
  );
}

class _ReviewError extends StatelessWidget {
  final String message;
  final VoidCallback retry;

  const _ReviewError({required this.message, required this.retry});

  @override
  Widget build(BuildContext context) => Center(
    child: ResponsiveContent(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            color: HomeColors.purple,
            size: 58,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(onRetry: retry),
        ],
      ),
    ),
  );
}
