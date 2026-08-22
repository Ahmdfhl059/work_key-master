import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/interviews_repo.dart';
import '../../logic/interviews_cubit/interviews_cubit.dart';
import '../../logic/interviews_cubit/interviews_state.dart';
import '../../shared/components/components.dart';
import '../../utils/constants.dart';
import 'interview_details_screen.dart';
import 'interview_strings.dart';
import 'widgets/interview_card.dart';
import 'widgets/interview_states.dart';

class InterviewsScreen extends StatelessWidget {
  const InterviewsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => InterviewsCubit(InterviewsRepo())..initialize(),
    child: const _InterviewsView(),
  );
}

class _InterviewsView extends StatefulWidget {
  const _InterviewsView();

  @override
  State<_InterviewsView> createState() => _InterviewsViewState();
}

class _InterviewsViewState extends State<_InterviewsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
  }

  void _loadMore() {
    if (_scrollController.position.extentAfter < 280) {
      context.read<InterviewsCubit>().load();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMore);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = InterviewStrings.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: Semantics(
          label: MaterialLocalizations.of(context).backButtonTooltip,
          button: true,
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: DefaultText(
          text: strings.title,
          style: TextStyle(
            color: context.appInk,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: BlocBuilder<InterviewsCubit, InterviewsState>(
        builder: (context, state) {
          final cubit = context.read<InterviewsCubit>();
          return RefreshIndicator(
            onRefresh: () => cubit.load(refresh: true),
            child: ResponsiveContent(
              maxWidth: 760,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: _InterviewsHeader(
                        subtitle: strings.subtitle,
                        count: state.total,
                      ),
                    ),
                  ),
                  if (state.loading)
                    const SliverToBoxAdapter(child: InterviewsLoadingState())
                  else if (state.error != null && state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: InterviewsErrorState(
                        onRetry: () => cubit.load(refresh: true),
                      ),
                    )
                  else if (state.items.isEmpty)
                    const SliverToBoxAdapter(child: InterviewsEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 40),
                      sliver: SliverList.builder(
                        itemCount:
                            state.items.length + (state.loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(18),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final interview = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InterviewCard(
                              interview: interview,
                              onTap: () async {
                                final updated = await navigateTo(
                                  context,
                                  InterviewDetailsScreen(
                                    interviewId: interview.id,
                                    initialInterview: interview,
                                  ),
                                );
                                if (updated != null && context.mounted) {
                                  cubit.updateInterview(updated);
                                }
                              },
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
      ),
    );
  }
}

class _InterviewsHeader extends StatelessWidget {
  final String subtitle;
  final int count;
  const _InterviewsHeader({required this.subtitle, required this.count});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF29B148), Color(0xFF0FA348)],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2818A949),
          blurRadius: 25,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.video_call_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DefaultText(
            text: subtitle,
            style: const TextStyle(
              color: Color(0xFFF0EDFF),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DefaultText(
              text: '$count',
              style: const TextStyle(
                color: HomeColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
