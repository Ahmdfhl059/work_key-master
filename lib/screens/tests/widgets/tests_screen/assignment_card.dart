part of '../../tests_screen.dart';

class _AssignmentCard extends StatelessWidget {
  final TestAssignmentModel assignment;
  const _AssignmentCard({required this.assignment});
  @override
  Widget build(BuildContext context) {
    final deadline = DateTime.tryParse(assignment.deadline)?.toLocal();
    return InkWell(
      onTap: () =>
          navigateTo(context, TestDetailsScreen(assignment: assignment)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.appDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.appSoftBrand,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.quiz_rounded, color: HomeColors.purple),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.test.title.isEmpty
                        ? 'Assigned test'
                        : assignment.test.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 9,
                    children: [
                      if (assignment.test.durationMinutes > 0)
                        Text(
                          context.tr(
                            'tests.minutes',
                            values: {'count': assignment.test.durationMinutes},
                          ),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      if (deadline != null)
                        Text(
                          context.tr(
                            'tests.due',
                            values: {
                              'date': DateFormat(
                                'MMM d, h:mm a',
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(deadline),
                            },
                          ),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _StatusChip(assignment.status),
          ],
        ),
      ),
    );
  }
}
