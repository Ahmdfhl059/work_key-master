import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/job_filter_schema.dart';
import 'package:work_key/logic/explore_jobs_cubit/explore_jobs_cubit.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

Future<void> showExploreFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ExploreJobsCubit>(),
        child: const ExploreFilterSheet(),
      ),
    );

class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({super.key});
  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late Map<String, dynamic> _draft;
  JobSortOption? _sort;

  @override
  void initState() {
    super.initState();
    final state = context.read<ExploreJobsCubit>().state;
    _draft = Map<String, dynamic>.from(state.filters);
    _sort = state.sort;
  }

  void _reset(JobFilterSchema schema) {
    setState(() {
      _draft = {};
      for (final filter in schema.filters) {
        if (filter.defaultValue != null && filter.parameter != null)
          _draft[filter.parameter!] = filter.defaultValue;
      }
      _sort = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final schema = context.read<ExploreJobsCubit>().state.schema;
    if (schema == null) return const SizedBox.shrink();
    final visible = schema.filters
        .where((filter) => filter.visibleWhen?.isVisible(_draft) ?? true)
        .toList();
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.bottom;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: (availableHeight * .92)
          .clamp(320.0, media.size.height * .92)
          .toDouble(),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultText(
                      text: 'Filters',
                      style: TextStyle(
                        color: context.appInk,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  DefaultTextButton(
                    text: 'Reset',
                    onPressed: () => _reset(schema),
                    textStyle: const TextStyle(
                      color: HomeColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  DefaultIconButton(
                    onPressed: () => Navigator.pop(context),
                    color: context.appInk,
                    size: 21,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (schema.sortOptions.isNotEmpty)
                    _SortField(
                      options: schema.sortOptions,
                      value: _sort,
                      onChanged: (value) => setState(() => _sort = value),
                    ),
                  ...visible.map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: _buildFilter(filter),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DefaultButton(
                background: HomeColors.purple,
                text: 'Show results',
                uppercase: false,
                borderRadius: 15,
                fontSize: 14,
                height: 54,
                onPress: () {
                  final visibleParameters = visible
                      .expand(
                        (filter) => [
                          if (filter.parameter != null) filter.parameter!,
                          ...filter.parameters.values,
                        ],
                      )
                      .toSet();
                  _draft.removeWhere(
                    (key, _) => !visibleParameters.contains(key),
                  );
                  context.read<ExploreJobsCubit>().applyFilters(
                    Map<String, dynamic>.from(_draft),
                    _sort,
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(JobFilterDefinition filter) {
    switch (filter.type) {
      case 'single_select':
        if (filter.key.toLowerCase().contains('skill') ||
            filter.label.toLowerCase().contains('skill')) {
          return _SearchableOptionsField(
            label: filter.label,
            options: filter.options,
            value: filter.parameter == null ? null : _draft[filter.parameter],
            onSelected: (value) => setState(() {
              if (filter.parameter != null) _draft[filter.parameter!] = value;
            }),
          );
        }
        return DropdownButtonFormField<dynamic>(
          value: filter.parameter == null ? null : _draft[filter.parameter],
          decoration: _decoration(filter.label),
          items: filter.options
              .map(
                (option) => DropdownMenuItem(
                  value: option.key,
                  child: DefaultText(
                    text: option.value,
                    style: TextStyle(color: context.appInk, fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() {
            if (filter.parameter != null) _draft[filter.parameter!] = value;
          }),
        );
      case 'boolean':
        final parameter = filter.parameter ?? filter.key;
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          activeColor: HomeColors.purple,
          title: DefaultText(
            text: filter.label,
            style: TextStyle(
              color: context.appInk,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          value: _draft[parameter] == true,
          onChanged: (value) => setState(() => _draft[parameter] = value),
        );
      case 'range':
        final minimum = filter.parameters['minimum'];
        final maximum = filter.parameters['maximum'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultText(
              text: filter.label,
              style: TextStyle(
                color: context.appInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: minimum == null
                        ? ''
                        : '${_draft[minimum] ?? ''}',
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Minimum'),
                    onChanged: (value) {
                      if (minimum != null) _draft[minimum] = value;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: maximum == null
                        ? ''
                        : '${_draft[maximum] ?? ''}',
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Maximum'),
                    onChanged: (value) {
                      if (maximum != null) _draft[maximum] = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case 'autocomplete':
        return _RemoteOptionsField(
          filter: filter,
          value: filter.parameter == null ? null : _draft[filter.parameter],
          onSelected: (value) => setState(() {
            if (filter.parameter != null) _draft[filter.parameter!] = value;
          }),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appDivider),
    ),
  );
}

class _SearchableOptionsField extends StatefulWidget {
  final String label;
  final List<JobFilterOption> options;
  final dynamic value;
  final ValueChanged<dynamic> onSelected;

  const _SearchableOptionsField({
    required this.label,
    required this.options,
    this.value,
    required this.onSelected,
  });

  @override
  State<_SearchableOptionsField> createState() =>
      _SearchableOptionsFieldState();
}

class _SearchableOptionsFieldState extends State<_SearchableOptionsField> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where(
          (option) => option.value.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final selected = widget.options
        .where((option) => option.key == widget.value)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: context.tr('explore.search_skills'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: selected == null
                ? null
                : IconButton(
                    onPressed: () => widget.onSelected(null),
                    icon: const Icon(Icons.close_rounded),
                  ),
            helperText: selected == null ? null : 'Selected: ${selected.value}',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        if (query.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appDivider),
            ),
            child: ListView(
              shrinkWrap: true,
              children: filtered
                  .map(
                    (option) => ListTile(
                      dense: true,
                      title: Text(option.value),
                      onTap: () {
                        widget.onSelected(option.key);
                        setState(() => query = '');
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _SortField extends StatelessWidget {
  final List<JobSortOption> options;
  final JobSortOption? value;
  final ValueChanged<JobSortOption?> onChanged;
  const _SortField({
    required this.options,
    this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<JobSortOption>(
    value: value,
    decoration: InputDecoration(
      labelText: context.tr('common.sort_by'),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainer,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    items: options
        .map(
          (option) =>
              DropdownMenuItem(value: option, child: Text(option.value)),
        )
        .toList(),
    onChanged: onChanged,
  );
}

class _RemoteOptionsField extends StatefulWidget {
  final JobFilterDefinition filter;
  final dynamic value;
  final ValueChanged<dynamic> onSelected;
  const _RemoteOptionsField({
    required this.filter,
    this.value,
    required this.onSelected,
  });
  @override
  State<_RemoteOptionsField> createState() => _RemoteOptionsFieldState();
}

class _RemoteOptionsFieldState extends State<_RemoteOptionsField> {
  Timer? _timer;
  List<JobFilterOption> _options = [];
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _search('');
  }

  void _search(String search) {
    final source = widget.filter.optionsSource;
    if (source == null || search.length < source.minimumSearchLength) return;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      try {
        final values = await context.read<ExploreJobsCubit>().loadOptions(
          source,
          search,
        );
        if (mounted) setState(() => _options = values);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        onChanged: _search,
        decoration: InputDecoration(
          labelText: widget.filter.label,
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      if (_options.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 6),
          constraints: const BoxConstraints(maxHeight: 160),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            shrinkWrap: true,
            children: _options
                .map(
                  (option) => ListTile(
                    dense: true,
                    title: Text(option.value),
                    onTap: () {
                      widget.onSelected(option.key);
                      setState(() => _options = []);
                    },
                  ),
                )
                .toList(),
          ),
        ),
    ],
  );
}
