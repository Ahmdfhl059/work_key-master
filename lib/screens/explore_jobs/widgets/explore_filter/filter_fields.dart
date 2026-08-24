part of '../explore_filter_sheet.dart';

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
