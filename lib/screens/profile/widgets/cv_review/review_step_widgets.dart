part of '../../cv_review_screen.dart';

class _ReviewStepBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _ReviewStepBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.person_outline_rounded,
      Icons.work_outline_rounded,
      Icons.school_outlined,
      Icons.auto_awesome_outlined,
      Icons.fact_check_outlined,
    ];
    const labels = [
      'cv.step_personal',
      'cv.step_experience',
      'cv.step_education',
      'cv.step_skills',
      'cv.step_final',
    ];
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final active = selected == index;
          final colors = Theme.of(context).colorScheme;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 105,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: active ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? colors.primary : colors.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 20,
                    color: active ? colors.onPrimary : colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.tr(labels[index]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? colors.onPrimary : colors.onSurface,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyReviewStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.no_changes_title'),
    icon: Icons.check_circle_outline_rounded,
    child: Text(
      context.tr('cv.no_changes_section'),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _StepControls extends StatelessWidget {
  final int step;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _StepControls({
    required this.step,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (step > 0)
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(context.tr('common.previous')),
          ),
        ),
      if (step > 0 && step < 4) const SizedBox(width: 10),
      if (step < 4)
        Expanded(
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(context.tr('common.next')),
          ),
        ),
    ],
  );
}
