import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/my_applications_cubit/my_applications_cubit.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

const applicationStatusLabels = <String, String>{
  'submitted': 'Submitted', 'under_review': 'Under review', 'shortlisted': 'Shortlisted', 'test_pending': 'Test pending', 'test_completed': 'Test completed',
  'interview_pending': 'Interview pending', 'interview_scheduled': 'Interview scheduled', 'interview_completed': 'Interview completed', 'final_review': 'Final review',
  'accepted': 'Accepted', 'rejected': 'Rejected', 'withdrawn': 'Withdrawn', 'on_hold': 'On hold', 'need_more_information': 'More information needed',
};

Future<void> showApplicationsFilterSheet(BuildContext context) => showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => BlocProvider.value(value: context.read<MyApplicationsCubit>(), child: const ApplicationsFilterSheet()));

class ApplicationsFilterSheet extends StatefulWidget { const ApplicationsFilterSheet({super.key}); @override State<ApplicationsFilterSheet> createState() => _ApplicationsFilterSheetState(); }
class _ApplicationsFilterSheetState extends State<ApplicationsFilterSheet> {
  late Set<String> statuses; late String sortBy; late String direction;
  @override void initState() { super.initState(); final state = context.read<MyApplicationsCubit>().state; statuses = state.statuses.toSet(); sortBy = state.sortBy; direction = state.sortDirection; }
  @override Widget build(BuildContext context) => Container(
    height: MediaQuery.sizeOf(context).height * .86,
    decoration: const BoxDecoration(color: HomeColors.canvas, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    child: SafeArea(top: false, child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 12, 8), child: Row(children: [const Expanded(child: DefaultText(text: 'Filters', style: TextStyle(color: HomeColors.ink, fontSize: 22, fontWeight: FontWeight.w900))), DefaultTextButton(text: 'Reset', onPressed: () => setState(() { statuses.clear(); sortBy = 'priority'; direction = 'desc'; }), textStyle: const TextStyle(color: HomeColors.purple, fontWeight: FontWeight.w700)), DefaultIconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), size: 21)])),
      const Divider(height: 1),
      Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
        const DefaultText(text: 'Status', style: TextStyle(color: HomeColors.ink, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8), ...applicationStatusLabels.entries.map((entry) => CheckboxListTile(contentPadding: EdgeInsets.zero, dense: true, activeColor: HomeColors.purple, value: statuses.contains(entry.key), title: Text(entry.value), onChanged: (value) => setState(() => value == true ? statuses.add(entry.key) : statuses.remove(entry.key)))),
        const SizedBox(height: 14), DropdownButtonFormField<String>(value: sortBy, decoration: const InputDecoration(labelText: 'Sort by'), items: const ['priority', 'updated_at', 'created_at', 'last_status_changed_at', 'deadline'].map((value) => DropdownMenuItem(value: value, child: Text(value.replaceAll('_', ' ')))).toList(), onChanged: (value) => setState(() => sortBy = value ?? sortBy)),
        const SizedBox(height: 14), SegmentedButton<String>(segments: const [ButtonSegment(value: 'desc', label: Text('Descending')), ButtonSegment(value: 'asc', label: Text('Ascending'))], selected: {direction}, onSelectionChanged: (value) => setState(() => direction = value.first)),
      ])),
      Padding(padding: const EdgeInsets.all(20), child: DefaultButton(background: HomeColors.purple, text: 'Apply filters', uppercase: false, borderRadius: 15, height: 54, fontSize: 14, onPress: () { context.read<MyApplicationsCubit>().applyFilters(statuses: statuses.toList(), sortBy: sortBy, direction: direction); Navigator.pop(context); })),
    ])),
  );
}
