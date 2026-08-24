part of '../explore_filter_sheet.dart';

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
