part of '../../tests_screen.dart';

class TestDetailsScreen extends StatelessWidget {
  final TestAssignmentModel assignment;
  const TestDetailsScreen({super.key, required this.assignment});

  bool get _canStart => assignment.canStart;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(context.tr('tests.details')),
    ),
    body: ResponsiveContent(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 110),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF29B148), Color(0xFF0FA348)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.quiz_rounded, color: Colors.white, size: 38),
                const SizedBox(height: 15),
                Text(
                  assignment.test.title.isEmpty
                      ? context.tr('tests.assigned')
                      : assignment.test.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (assignment.test.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    assignment.test.description,
                    style: const TextStyle(
                      color: Color(0xFFE8F7ED),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Info(
            title: context.tr('tests.information'),
            child: Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                if (assignment.test.durationMinutes > 0)
                  _Fact(
                    Icons.timer_outlined,
                    context.tr(
                      'tests.minutes',
                      values: {'count': assignment.test.durationMinutes},
                    ),
                  ),
                if (assignment.test.maxScore > 0)
                  _Fact(
                    Icons.stars_outlined,
                    context.tr(
                      'tests.points',
                      values: {'count': assignment.test.maxScore},
                    ),
                  ),
                if (assignment.deadline.isNotEmpty)
                  _Fact(Icons.event_outlined, assignment.deadline),
              ],
            ),
          ),
          if (assignment.instructions.isNotEmpty ||
              assignment.test.instructions.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Info(
              title: context.tr('tests.instructions'),
              child: Text(
                assignment.instructions.isNotEmpty
                    ? assignment.instructions
                    : assignment.test.instructions,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: BlocConsumer<TestsCubit, TestsStates>(
          listener: (context, state) {
            if (state is TestStartedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('tests.started'))),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TestAttemptScreen(
                    assignment: state.assignment,
                    attempt: state.attempt,
                  ),
                ),
              );
            } else if (state is TestsErrorState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) => FilledButton(
            onPressed: !_canStart || state is TestsLoadingState
                ? null
                : () => _confirmStart(context),
            style: FilledButton.styleFrom(
              backgroundColor: HomeColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: state is TestsLoadingState
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _canStart ? context.tr('tests.start') : assignment.status,
                  ),
          ),
        ),
      ),
    ),
  );

  Future<void> _confirmStart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Start this test?')),
        content: Text(
          context.tr('The timer may begin immediately after you start.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('common.start')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted)
      context.read<TestsCubit>().startTest(assignment);
  }
}
