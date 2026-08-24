part of '../../activity_screen.dart';

class _ActivityTabs extends StatelessWidget {
  final ActivityState state;
  final ActivityStrings strings;
  final ValueChanged<String> onSelect;

  const _ActivityTabs({
    required this.state,
    required this.strings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tabs = [
      ('all', strings.all),
      ('requires_action', strings.action),
      ('today', strings.today),
      ('this_week', strings.week),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final selected = state.group == tab.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 7),
            child: ChoiceChip(
              selected: selected,
              backgroundColor: colors.surfaceContainer,
              selectedColor: colors.primaryContainer,
              side: BorderSide(
                color: selected ? colors.primary : colors.outlineVariant,
              ),
              onSelected: (_) => onSelect(tab.$1),
              label: Text(
                '${tab.$2} ${state.summary.forGroup(tab.$1)}',
                style: TextStyle(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ActionBanner({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: HomeColors.warning),
            const SizedBox(width: 9),
            Expanded(
              child: DefaultText(
                text: title,
                style: TextStyle(
                  color: context.appInk,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
