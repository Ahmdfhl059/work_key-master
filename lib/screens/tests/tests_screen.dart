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

part 'widgets/tests_screen/assignment_card.dart';
part 'widgets/tests_screen/test_details.dart';
part 'widgets/tests_screen/detail_widgets.dart';

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
