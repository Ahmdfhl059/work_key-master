part of '../../cv_review_screen.dart';

class _SuggestionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Set<int> busyIds;
  final bool bulkBusy;
  final Future<void> Function(Map<String, dynamic>, bool) decide;
  final Future<void> Function(List<Map<String, dynamic>>, bool) decideBulk;
  final Future<void> Function(Map<String, dynamic>) edit;

  const _SuggestionsCard({
    required this.suggestions,
    required this.busyIds,
    required this.bulkBusy,
    required this.decide,
    required this.decideBulk,
    required this.edit,
  });

  bool get _hasPending =>
      suggestions.any((item) => _localizedKey(item['status']) == 'pending');

  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.review_changes'),
    icon: Icons.compare_arrows_rounded,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: bulkBusy || !_hasPending
                    ? null
                    : () => decideBulk(suggestions, false),
                icon: const Icon(Icons.undo_rounded),
                label: Text(context.tr('cv.bulk_keep_current')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: bulkBusy || !_hasPending
                    ? null
                    : () => decideBulk(suggestions, true),
                icon: bulkBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded),
                label: Text(context.tr('cv.bulk_use_cv')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ...suggestions.map((suggestion) {
          final actionable = suggestion['is_actionable'] == true;
          final editable = _isSuggestionEditable(suggestion);
          final selected = suggestion['selected_decision']?.toString();
          final id = int.tryParse('${suggestion['id'] ?? ''}') ?? -1;
          final disabled = busyIds.contains(id) || bulkBusy;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.appDivider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.appSoftBrand,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        _suggestionIcon(suggestion['entity_type']),
                        color: HomeColors.purple,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DefaultText(
                        text: _localizedLabel(
                          suggestion['display_group'] ??
                              suggestion['entity_type'],
                          context.tr('cv.profile_information'),
                        ),
                        style: TextStyle(
                          color: context.appInk,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _DecisionChip(selected: selected),
                  ],
                ),
                const SizedBox(height: 11),
                _ValueComparison(
                  label: context.tr('cv.current'),
                  value: suggestion['current_value'],
                  icon: Icons.history_rounded,
                ),
                const SizedBox(height: 8),
                _ValueComparison(
                  label: selected == 'edit'
                      ? context.tr('cv.edited_value')
                      : context.tr('cv.from_cv'),
                  value:
                      selected == 'edit' && suggestion['editable_value'] != null
                      ? suggestion['editable_value']
                      : suggestion['proposed_value'],
                  icon: selected == 'edit'
                      ? Icons.edit_note_rounded
                      : Icons.auto_awesome_rounded,
                  highlighted: true,
                ),
                if (actionable) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: disabled
                              ? null
                              : () => decide(suggestion, false),
                          icon: const Icon(Icons.undo_rounded, size: 17),
                          label: Text(
                            selected == 'keep_current' || selected == 'ignore'
                                ? context.tr('cv.current_kept')
                                : context.tr('cv.keep_current'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: disabled
                              ? null
                              : () => decide(suggestion, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: HomeColors.purple,
                          ),
                          icon: const Icon(Icons.done_rounded, size: 17),
                          label: Text(
                            selected?.startsWith('accept') == true
                                ? context.tr('cv.cv_selected')
                                : context.tr('cv.use_cv'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (editable) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: disabled ? null : () => edit(suggestion),
                        icon: const Icon(Icons.edit_rounded, size: 17),
                        label: Text(context.tr('cv.edit_before_confirm')),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        }),
      ],
    ),
  );
}

class _DecisionChip extends StatelessWidget {
  final String? selected;

  const _DecisionChip({required this.selected});

  @override
  Widget build(BuildContext context) {
    if (selected == null || selected!.isEmpty) return const SizedBox.shrink();
    final edited = selected == 'edit';
    final kept = selected == 'keep_current' || selected == 'ignore';
    final color = edited
        ? Theme.of(context).colorScheme.tertiary
        : kept
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;
    final key = edited
        ? 'cv.edited'
        : kept
        ? 'cv.kept'
        : 'cv.selected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        context.tr(key),
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

IconData _suggestionIcon(dynamic entity) {
  final value = _localizedKey(entity).toLowerCase();
  if (value.contains('experience')) return Icons.work_history_outlined;
  if (value.contains('education')) return Icons.school_outlined;
  if (value.contains('skill')) return Icons.bolt_rounded;
  return Icons.person_outline_rounded;
}

class _ValueComparison extends StatelessWidget {
  final String label;
  final dynamic value;
  final IconData icon;
  final bool highlighted;

  const _ValueComparison({
    required this.label,
    required this.value,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final lines = _displayLines(value, context: context);
    final colors = Theme.of(context).colorScheme;
    final accent = highlighted ? colors.primary : colors.secondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted
            ? colors.primaryContainer.withValues(alpha: .28)
            : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: accent.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (lines.isEmpty)
            Text(
              context.tr('common.not_provided'),
              style: TextStyle(color: context.appMuted, fontSize: 11.5),
            )
          else
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: CircleAvatar(radius: 2.2, backgroundColor: accent),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        line,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 11.5,
                          height: 1.45,
                          fontWeight: highlighted
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
