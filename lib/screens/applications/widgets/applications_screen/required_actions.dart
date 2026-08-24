part of '../../applications_screen.dart';

class _RequiredActionsBanner extends StatelessWidget {
  final MyApplicationsState state;
  final String title;
  final VoidCallback onTap;

  const _RequiredActionsBanner({
    required this.state,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final informationCount = state.items
        .where((item) => item.nextAction?.type.key == 'submit_information')
        .length;
    final testCount = state.items
        .where((item) => item.nextAction?.type.key == 'complete_test')
        .length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: HomeColors.warning,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: title,
                    style: TextStyle(
                      color: context.appInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (state.group == 'all' &&
                      (informationCount > 0 || testCount > 0)) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        if (informationCount > 0)
                          _ActionCount(
                            label: 'Information required',
                            count: informationCount,
                          ),
                        if (testCount > 0)
                          _ActionCount(
                            label: 'Tests to complete',
                            count: testCount,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.arrow_forward_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCount extends StatelessWidget {
  final String label;
  final int count;

  const _ActionCount({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
    ),
    child: DefaultText(
      text: '${context.tr(label)} ($count)',
      style: const TextStyle(
        color: HomeColors.warning,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
