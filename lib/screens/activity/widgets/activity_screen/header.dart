part of '../../activity_screen.dart';

class _ActivityHeader extends StatelessWidget {
  final ActivityState state;
  final ActivityStrings strings;
  final bool searching;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onMarkAllRead;
  final VoidCallback onFilter;
  final ValueChanged<String> onSelectGroup;

  const _ActivityHeader({
    required this.state,
    required this.strings,
    required this.searching,
    required this.searchController,
    required this.onToggleSearch,
    required this.onSearch,
    required this.onClearSearch,
    required this.onMarkAllRead,
    required this.onFilter,
    required this.onSelectGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DefaultText(
                  text: strings.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (state.summary.unreadNotifications > 0)
                DefaultTextButton(
                  text: strings.markAll,
                  onPressed: state.markingRead ? null : onMarkAllRead,
                  textStyle: const TextStyle(
                    color: HomeColors.purple,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Badge(
                isLabelVisible: state.summary.unreadNotifications > 0,
                label: Text('${state.summary.unreadNotifications}'),
                child: DefaultIconButton(
                  onPressed: onToggleSearch,
                  color: HomeColors.brand,
                  size: 21,
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
              Badge(
                isLabelVisible: state.activeFilterCount > 0,
                label: Text('${state.activeFilterCount}'),
                child: DefaultIconButton(
                  onPressed: onFilter,
                  color: HomeColors.purple,
                  size: 21,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: searching
                ? Padding(
                    key: const ValueKey('activity-search'),
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: strings.search,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: context.appDivider),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          _ActivityTabs(
            state: state,
            strings: strings,
            onSelect: onSelectGroup,
          ),
          if (state.summary.requiresAction > 0 &&
              state.group != 'requires_action') ...[
            const SizedBox(height: 13),
            _ActionBanner(
              title: strings.banner(state.summary.requiresAction),
              onTap: () => onSelectGroup('requires_action'),
            ),
          ],
          if (state.summary.all > 0) ...[
            const SizedBox(height: 15),
            _ActivitySummary(summary: state.summary),
          ],
        ],
      ),
    );
  }
}
