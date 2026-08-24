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

import '../../localization/app_localizations.dart';

part 'widgets/activity_screen/header.dart';
part 'widgets/activity_screen/tabs_actions.dart';
part 'widgets/activity_screen/summary_schedule.dart';

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
      color: Theme.of(context).scaffoldBackgroundColor,
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
            child: ActivityErrorState(retry: () => cubit.load(refresh: true)),
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
                style: TextStyle(
                  color: context.appInk,
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
              message: strings.empty(state.group, state.search.isNotEmpty),
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
              style: TextStyle(
                color: context.appInk,
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
