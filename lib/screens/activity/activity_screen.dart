import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/activity_response_model.dart';
import 'package:work_key/data/repo/activity_repo.dart';
import 'package:work_key/logic/activity_cubit/activity_cubit.dart';
import 'package:work_key/logic/activity_cubit/activity_state.dart';
import 'package:work_key/screens/activity/activity_navigation.dart';
import 'package:work_key/screens/activity/activity_strings.dart';
import 'package:work_key/screens/activity/widgets/activity_card.dart';
import 'package:work_key/screens/activity/widgets/activity_filter_sheet.dart';
import 'package:work_key/screens/activity/widgets/activity_states.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityCubit(ActivityRepo())..initialize(),
      child: const _ActivityView(),
    );
  }
}

class _ActivityView extends StatefulWidget {
  const _ActivityView();

  @override
  State<_ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<_ActivityView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 280) {
      context.read<ActivityCubit>().load();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeColors.canvas,
      child: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          final cubit = context.read<ActivityCubit>();
          final strings = ActivityStrings.of(context);
          return RefreshIndicator(
            onRefresh: () => cubit.load(refresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: ResponsiveContent(
                    child: _ActivityHeader(
                      state: state,
                      strings: strings,
                      searching: _searching,
                      searchController: _searchController,
                      onToggleSearch: () {
                        setState(() => _searching = !_searching);
                      },
                      onSearch: cubit.search,
                      onClearSearch: () {
                        _searchController.clear();
                        cubit.search('');
                      },
                      onMarkAllRead: cubit.markAllRead,
                      onFilter: () => showActivityFilterSheet(context),
                      onSelectGroup: cubit.selectGroup,
                    ),
                  ),
                ),
                ..._buildContent(state, strings, cubit),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(
    ActivityState state,
    ActivityStrings strings,
    ActivityCubit cubit,
  ) {
    if (state.loading) {
      return const [
        SliverToBoxAdapter(
          child: ResponsiveContent(child: ActivityLoadingState()),
        ),
      ];
    }

    if (state.error != null && state.feed.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: ResponsiveContent(
            child: ActivityErrorState(
              message: state.error!,
              retry: () => cubit.load(refresh: true),
            ),
          ),
        ),
      ];
    }

    return [
      if (state.required.isNotEmpty && state.group != 'requires_action')
        ..._activitySection(
          strings.required,
          state.required.take(3).toList(),
          cubit,
        ),
      if (state.schedule.isNotEmpty)
        SliverToBoxAdapter(
          child: ResponsiveContent(
            child: _ScheduleSection(
              title: strings.schedule,
              items: state.schedule,
              onOpen: (item) => _open(cubit, item),
            ),
          ),
        ),
      if (state.feed.isNotEmpty)
        SliverToBoxAdapter(
          child: ResponsiveContent(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DefaultText(
                text: strings.feed,
                style: const TextStyle(
                  color: HomeColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      if (state.feed.isEmpty)
        SliverToBoxAdapter(
          child: ResponsiveContent(
            child: ActivityEmptyState(
              message: strings.empty(
                state.group,
                state.search.isNotEmpty,
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 120),
          sliver: SliverList.builder(
            itemCount: state.feed.length + (state.loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.feed.length) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final item = state.feed[index];
              return ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: ActivityCard(
                    item: item,
                    onTap: () => _open(cubit, item),
                  ),
                ),
              );
            },
          ),
        ),
    ];
  }

  List<Widget> _activitySection(
    String title,
    List<ActivityItem> items,
    ActivityCubit cubit,
  ) {
    return [
      SliverToBoxAdapter(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: DefaultText(
              text: title,
              style: const TextStyle(
                color: HomeColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
      SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ResponsiveContent(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: ActivityCard(
                item: items[index],
                onTap: () => _open(cubit, items[index]),
              ),
            ),
          );
        },
      ),
    ];
  }

  void _open(ActivityCubit cubit, ActivityItem item) {
    cubit.openItem(item, () => ActivityNavigation.open(context, item));
  }
}

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
                  style: const TextStyle(
                    color: HomeColors.ink,
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
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: HomeColors.divider,
                          ),
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
              selectedColor: HomeColors.softPurple,
              side: BorderSide(
                color: selected ? HomeColors.purple : HomeColors.divider,
              ),
              onSelected: (_) => onSelect(tab.$1),
              label: Text(
                '${tab.$2} ${state.summary.forGroup(tab.$1)}',
                style: TextStyle(
                  color: selected ? HomeColors.purple : HomeColors.muted,
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
          color: const Color(0xFFFFF2DA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: HomeColors.warning),
            const SizedBox(width: 9),
            Expanded(
              child: DefaultText(
                text: title,
                style: const TextStyle(
                  color: HomeColors.ink,
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

class _ActivitySummary extends StatelessWidget {
  final ActivitySummary summary;

  const _ActivitySummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Today', summary.today, Icons.today_rounded),
      ('Tests', summary.tests, Icons.quiz_outlined),
      ('Interviews', summary.interviews, Icons.video_call_outlined),
      ('Information', summary.informationRequests, Icons.description_outlined),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: HomeColors.divider),
            ),
            child: Row(
              children: [
                Icon(item.$3, size: 16, color: HomeColors.purple),
                const SizedBox(width: 6),
                Text(
                  '${item.$1} ${item.$2}',
                  style: const TextStyle(
                    color: HomeColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final String title;
  final List<ActivityItem> items;
  final ValueChanged<ActivityItem> onOpen;

  const _ScheduleSection({
    required this.title,
    required this.items,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultText(
            text: title,
            style: const TextStyle(
              color: HomeColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: ActivityCard(
                    item: item,
                    compact: true,
                    onTap: () => onOpen(item),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
