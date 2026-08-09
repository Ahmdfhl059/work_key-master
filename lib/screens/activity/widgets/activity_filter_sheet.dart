import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/activity_cubit/activity_cubit.dart';
import 'package:work_key/logic/activity_cubit/activity_state.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

Future<void> showActivityFilterSheet(BuildContext context) async {
  final cubit = context.read<ActivityCubit>();
  final initial = cubit.state;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _Sheet(initial: initial),
    ),
  );
}

class _Sheet extends StatefulWidget {
  final ActivityState initial;

  const _Sheet({required this.initial});

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  late List<String> types;
  late String sort, direction;
  DateTime? from, to;
  static const options = {
    'test': 'Tests',
    'interview': 'Interviews',
    'information_request': 'Information requests',
    'application_status': 'Application updates',
    'application_reminder': 'Reminders',
    'final_decision': 'Final decisions',
  };

  @override
  void initState() {
    super.initState();
    types = [...widget.initial.types];
    sort = widget.initial.sortBy;
    direction = widget.initial.sortDirection;
    from = widget.initial.dateFrom;
    to = widget.initial.dateTo;
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: DefaultText(
                      text: 'Filter activity',
                      style: TextStyle(
                        color: HomeColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const DefaultText(
                text: 'Activity type',
                style: TextStyle(
                  color: HomeColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: options.entries
                    .map(
                      (entry) => FilterChip(
                        label: Text(entry.value),
                        selected: types.contains(entry.key),
                        onSelected: (selected) => setState(
                          () => selected
                              ? types.add(entry.key)
                              : types.remove(entry.key),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              const DefaultText(
                text: 'Date range',
                style: TextStyle(
                  color: HomeColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _date(true),
                      icon: const Icon(Icons.calendar_today_outlined, size: 16),
                      label: Text(
                        from == null
                            ? 'From'
                            : '${from!.year}-${from!.month}-${from!.day}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _date(false),
                      icon: const Icon(Icons.event_outlined, size: 16),
                      label: Text(
                        to == null
                            ? 'To'
                            : '${to!.year}-${to!.month}-${to!.day}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: sort,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: const [
                  DropdownMenuItem(value: 'priority', child: Text('Priority')),
                  DropdownMenuItem(value: 'occurred_at', child: Text('Newest')),
                  DropdownMenuItem(
                    value: 'due_at',
                    child: Text('Nearest deadline'),
                  ),
                ],
                onChanged: (v) => setState(() => sort = v ?? sort),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'desc', label: Text('Descending')),
                  ButtonSegment(value: 'asc', label: Text('Ascending')),
                ],
                selected: {direction},
                onSelectionChanged: (value) =>
                    setState(() => direction = value.first),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<ActivityCubit>().applyFilters(
                          types: const [],
                          sortBy: 'priority',
                          sortDirection: 'desc',
                          clearDates: true,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DefaultButton(
                      background: HomeColors.purple,
                      text: 'Apply',
                      uppercase: false,
                      onPress: () {
                        context.read<ActivityCubit>().applyFilters(
                          types: types,
                          sortBy: sort,
                          sortDirection: direction,
                          from: from,
                          to: to,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _date(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (start ? from : to) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null)
      setState(() {
        if (start)
          from = picked;
        else
          to = picked;
      });
  }
}
