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

part 'widgets/applications_screen/tests_shortcut.dart';
part 'widgets/applications_screen/required_actions.dart';
part 'widgets/applications_screen/group_tabs.dart';

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
