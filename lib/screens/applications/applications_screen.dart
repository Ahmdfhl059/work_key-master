import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/repo/application_repo.dart';
import 'package:work_key/logic/my_applications_cubit/my_applications_cubit.dart';
import 'package:work_key/logic/my_applications_cubit/my_applications_state.dart';
import 'package:work_key/screens/applications/applications_strings.dart';
import 'package:work_key/screens/tests/tests_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/localization/app_localizations.dart';

import 'widgets/application_card.dart';
import 'widgets/applications_filter_sheet.dart';
import 'widgets/applications_states.dart';

class ApplicationsScreen extends StatelessWidget {
  final VoidCallback? onExplore;

  const ApplicationsScreen({super.key, this.onExplore});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MyApplicationsCubit(ApplicationRepo())..initialize(),
    child: _ApplicationsView(onExplore: onExplore),
  );
}

class _ApplicationsView extends StatefulWidget {
  final VoidCallback? onExplore;

  const _ApplicationsView({this.onExplore});
  @override
  State<_ApplicationsView> createState() => _ApplicationsViewState();
}

class _ApplicationsViewState extends State<_ApplicationsView> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 260) {
        context.read<MyApplicationsCubit>().load();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<MyApplicationsCubit, MyApplicationsState>(
    builder: (context, state) {
      final strings = ApplicationsStrings.of(context);
      final cubit = context.read<MyApplicationsCubit>();
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: RefreshIndicator(
          onRefresh: () => cubit.load(refresh: true),
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveContent(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DefaultText(
                                text: strings.title,
                                style: TextStyle(
                                  color: context.appInk,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Semantics(
                              label: strings.searchHint,
                              button: true,
                              child: DefaultIconButton(
                                onPressed: () =>
                                    setState(() => _searching = !_searching),
                                color: HomeColors.brand,
                                size: 22,
                                icon: const Icon(Icons.search_rounded),
                              ),
                            ),
                            Badge(
                              isLabelVisible: state.statuses.isNotEmpty,
                              label: Text('${state.statuses.length}'),
                              child: Semantics(
                                label: 'Filters',
                                button: true,
                                child: DefaultIconButton(
                                  onPressed: () =>
                                      showApplicationsFilterSheet(context),
                                  color: HomeColors.purple,
                                  size: 22,
                                  icon: const Icon(Icons.tune_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _searching
                              ? Padding(
                                  key: const ValueKey('search'),
                                  padding: const EdgeInsets.only(top: 12),
                                  child: TextField(
                                    controller: _search,
                                    onChanged: cubit.setSearch,
                                    decoration: InputDecoration(
                                      hintText: strings.searchHint,
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                      ),
                                      suffixIcon: _search.text.isEmpty
                                          ? null
                                          : IconButton(
                                              onPressed: () {
                                                _search.clear();
                                                cubit.setSearch('');
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.close_rounded,
                                              ),
                                            ),
                                      filled: true,
                                      fillColor: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: context.appDivider,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 18),
                        _TestsShortcut(
                          onTap: () => navigateTo(context, const TestsScreen()),
                        ),
                        const SizedBox(height: 14),
                        _GroupTabs(
                          state: state,
                          strings: strings,
                          onTap: cubit.selectGroup,
                        ),
                        if (state.counts.requiresAction > 0 &&
                            state.group != 'completed') ...[
                          const SizedBox(height: 14),
                          _RequiredActionsBanner(
                            state: state,
                            title: strings.actionBanner(
                              state.counts.requiresAction,
                            ),
                            onTap: () => cubit.selectGroup('requires_action'),
                          ),
                        ],
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.loading)
                const SliverToBoxAdapter(child: ApplicationsLoadingState())
              else if (state.error != null && state.items.isEmpty)
                SliverToBoxAdapter(
                  child: ApplicationsErrorState(
                    onRetry: () => cubit.load(refresh: true),
                  ),
                )
              else if (state.items.isEmpty)
                SliverToBoxAdapter(
                  child: ApplicationsEmptyState(
                    message: strings.empty(state.group),
                    onExplore: widget.onExplore,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120),
                  sliver: SliverList.builder(
                    itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(18),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ResponsiveContent(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ApplicationCard(
                            application: state.items[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _TestsShortcut extends StatelessWidget {
  final VoidCallback onTap;

  const _TestsShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: context.appSoftBrand,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.quiz_rounded, color: HomeColors.purple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: context.tr('tests.title'),
                    style: TextStyle(
                      color: context.appInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  DefaultText(
                    text: context.tr('tests.short_description'),
                    style: TextStyle(color: context.appMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: HomeColors.purple,
            ),
          ],
        ),
      ),
    ),
  );
}

class _RequiredActionsBanner extends StatelessWidget {
  final MyApplicationsState state;
  final String title;
  final VoidCallback onTap;

  const _RequiredActionsBanner({
    required this.state,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final informationCount = state.items
        .where((item) => item.nextAction?.type.key == 'submit_information')
        .length;
    final testCount = state.items
        .where((item) => item.nextAction?.type.key == 'complete_test')
        .length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: HomeColors.warning,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: title,
                    style: TextStyle(
                      color: context.appInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (state.group == 'all' &&
                      (informationCount > 0 || testCount > 0)) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        if (informationCount > 0)
                          _ActionCount(
                            label: 'Information required',
                            count: informationCount,
                          ),
                        if (testCount > 0)
                          _ActionCount(
                            label: 'Tests to complete',
                            count: testCount,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.arrow_forward_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCount extends StatelessWidget {
  final String label;
  final int count;

  const _ActionCount({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
    ),
    child: DefaultText(
      text: '${context.tr(label)} ($count)',
      style: const TextStyle(
        color: HomeColors.warning,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

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
