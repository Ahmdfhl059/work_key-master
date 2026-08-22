import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/test_assignment_model.dart';
import '../../logic/tests_cubit/tests_cubit.dart';
import '../../logic/tests_cubit/tests_state.dart';
import '../../shared/components/components.dart';
import '../../utils/constants.dart';
import '../../localization/app_localizations.dart';
import 'test_attempt_screen.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});
  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TestsCubit>().getMyTests();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(context.tr('tests.title')),
    ),
    body: BlocBuilder<TestsCubit, TestsStates>(
      builder: (context, state) {
        if (state is TestsLoadingState)
          return const Center(child: CircularProgressIndicator());
        if (state is TestsErrorState)
          return _TestState(
            icon: Icons.cloud_off_rounded,
            text: context.tr('tests.load_error'),
            action: () => context.read<TestsCubit>().getMyTests(),
          );
        if (state is GetAssignedTestsSuccessState) {
          if (state.assignments.isEmpty)
            return _TestState(
              icon: Icons.quiz_outlined,
              text: context.tr('tests.empty'),
            );
          return RefreshIndicator(
            onRefresh: () async => context.read<TestsCubit>().getMyTests(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              itemCount: state.assignments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 11),
              itemBuilder: (_, index) =>
                  _AssignmentCard(assignment: state.assignments[index]),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );
}

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

class _Info extends StatelessWidget {
  final String title;
  final Widget child;
  const _Info({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.appDivider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Fact(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: HomeColors.purple),
      const SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: context.appSoftBrand,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      status.isEmpty ? 'assigned' : status.replaceAll('_', ' '),
      style: const TextStyle(
        color: HomeColors.purple,
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _TestState extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? action;
  const _TestState({required this.icon, required this.text, this.action});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 58,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(text),
        if (action != null) ...[
          const SizedBox(height: 16),
          ModernRetryButton(onRetry: () => action?.call()),
        ],
      ],
    ),
  );
}
