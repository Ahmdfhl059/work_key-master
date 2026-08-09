import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/repo/explore_jobs_repo.dart';
import 'package:work_key/logic/explore_jobs_cubit/explore_jobs_cubit.dart';
import 'package:work_key/logic/explore_jobs_cubit/explore_jobs_state.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import 'widgets/explore_filter_sheet.dart';
import 'widgets/explore_job_card.dart';
import 'widgets/explore_states.dart';

class ExploreJobsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final ExploreTab? initialTab;

  const ExploreJobsScreen({super.key, this.onBack, this.initialTab});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        ExploreJobsCubit(ExploreJobsRepo())..initialize(initialTab: initialTab),
    child: _ExploreJobsView(onBack: onBack),
  );
}

class _ExploreJobsView extends StatefulWidget {
  final VoidCallback? onBack;

  const _ExploreJobsView({this.onBack});
  @override
  State<_ExploreJobsView> createState() => _ExploreJobsViewState();
}

class _ExploreJobsViewState extends State<_ExploreJobsView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 280)
        context.read<ExploreJobsCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    color: HomeColors.canvas,
    child: BlocBuilder<ExploreJobsCubit, ExploreJobsState>(
      builder: (context, state) {
        final cubit = context.read<ExploreJobsCubit>();
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ExploreTabs(state: state, onTap: cubit.selectTab),
                        if (state.tab == ExploreTab.all) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: cubit.search,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: 'Search jobs or companies',
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                    ),
                                    suffixIcon: _searchController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              cubit.search('');
                                              setState(() {});
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                            ),
                                          ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: HomeColors.divider,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Badge(
                                isLabelVisible: state.activeFilterCount > 0,
                                label: Text('${state.activeFilterCount}'),
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: HomeColors.purple,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: DefaultIconButton(
                                    onPressed: () {
                                      if (state.schema != null)
                                        showExploreFilterSheet(context);
                                    },
                                    color: state.schema == null
                                        ? Colors.white54
                                        : Colors.white,
                                    size: 22,
                                    icon: const Icon(Icons.filter_alt_outlined),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (state.schemaError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: DefaultText(
                                text:
                                    'Filter options are currently unavailable.',
                                style: const TextStyle(
                                  color: HomeColors.warning,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (state.loading ||
                  (state.schemaLoading &&
                      state.forYou.isEmpty &&
                      state.latest.isEmpty &&
                      state.all.isEmpty))
                const SliverToBoxAdapter(child: ExploreLoadingState())
              else if (state.error != null && state.visibleJobs.isEmpty)
                SliverToBoxAdapter(
                  child: ExploreErrorState(
                    message: state.error!,
                    onRetry: () => cubit.load(refresh: true),
                  ),
                )
              else if (state.visibleJobs.isEmpty)
                const SliverToBoxAdapter(child: ExploreEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120),
                  sliver: SliverList.builder(
                    itemCount:
                        state.visibleJobs.length + (state.loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.visibleJobs.length)
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      return ResponsiveContent(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExploreJobCard(
                            job: state.visibleJobs[index],
                            showMatch: state.tab == ExploreTab.forYou,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class _ExploreTabs extends StatelessWidget {
  final ExploreJobsState state;
  final ValueChanged<ExploreTab> onTap;
  const _ExploreTabs({required this.state, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final tabs = [
      if (state.isAuthenticated) ExploreTab.forYou,
      ExploreTab.latest,
      ExploreTab.all,
    ];
    String label(ExploreTab tab) => tab == ExploreTab.forYou
        ? 'For You'
        : tab == ExploreTab.latest
        ? 'Latest'
        : 'All Jobs';
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: HomeColors.softPurple,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: tabs.map((tab) {
          final selected = state.tab == tab;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(tab),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? const [
                          BoxShadow(color: Color(0x126554D9), blurRadius: 12),
                        ]
                      : null,
                ),
                child: Center(
                  child: DefaultText(
                    text: label(tab),
                    style: TextStyle(
                      color: selected ? HomeColors.purple : HomeColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
