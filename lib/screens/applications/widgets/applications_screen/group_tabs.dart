part of '../../applications_screen.dart';

class _GroupTabs extends StatelessWidget {
  final MyApplicationsState state;
  final ApplicationsStrings strings;
  final ValueChanged<String> onTap;
  const _GroupTabs({
    required this.state,
    required this.strings,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final groups = [
      ('all', strings.all),
      ('active', strings.active),
      ('requires_action', strings.action),
      ('completed', strings.completed),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: groups.map((item) {
          final selected = state.group == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              onSelected: (_) => onTap(item.$1),
              selectedColor: context.appSoftBrand,
              side: BorderSide(
                color: selected ? HomeColors.purple : context.appDivider,
              ),
              label: Text(
                '${item.$2} ${state.counts.forGroup(item.$1)}',
                style: TextStyle(
                  color: selected ? HomeColors.purple : context.appMuted,
                  fontSize: 12,
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
