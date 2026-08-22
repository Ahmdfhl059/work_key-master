import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/job_filter_schema.dart';
import 'package:work_key/data/models/job_model.dart';
import 'package:work_key/data/repo/explore_jobs_repo.dart';
import 'package:work_key/utils/shared%20preferences.dart';
import 'explore_jobs_state.dart';

class ExploreJobsCubit extends Cubit<ExploreJobsState> {
  final ExploreJobsRepo repo;
  Timer? _searchDebounce;
  ExploreJobsCubit(this.repo) : super(const ExploreJobsState());

  Future<void> initialize({
    ExploreTab? initialTab,
    Map<String, dynamic> initialFilters = const {},
  }) async {
    final authenticated = CacheHelper.getData(key: 'token') != null;
    final language = CacheHelper.getData(key: 'LOCALE')?.toString() ?? 'en';
    final resolvedTab = initialTab == ExploreTab.forYou && !authenticated
        ? ExploreTab.all
        : initialTab ?? (authenticated ? ExploreTab.forYou : ExploreTab.all);
    emit(
      state.copyWith(
        schemaLoading: true,
        isAuthenticated: authenticated,
        tab: resolvedTab,
      ),
    );
    try {
      final schema = await repo.getFilterSchema(language);
      final defaults = <String, dynamic>{};
      for (final filter in schema.filters) {
        if (filter.defaultValue != null && filter.parameter != null)
          defaults[filter.parameter!] = filter.defaultValue;
      }
      emit(
        state.copyWith(
          schema: schema,
          schemaLoading: false,
          filters: {...defaults, ...initialFilters},
        ),
      );
    } catch (error) {
      emit(state.copyWith(schemaLoading: false, schemaError: error.toString()));
    }
    await load(refresh: true);
  }

  Future<void> selectTab(ExploreTab tab) async {
    if (tab == ExploreTab.forYou && !state.isAuthenticated) return;
    emit(state.copyWith(tab: tab, clearError: true));
    if (state.visibleJobs.isEmpty) await load(refresh: true);
  }

  void search(String value) {
    if (state.tab != ExploreTab.all) return;
    _searchDebounce?.cancel();
    emit(state.copyWith(search: value));
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => load(refresh: true),
    );
  }

  Future<void> applyFilters(
    Map<String, dynamic> values,
    JobSortOption? sort,
  ) async {
    if (state.tab != ExploreTab.all) return;
    emit(state.copyWith(filters: values, sort: sort));
    await load(refresh: true);
  }

  Future<List<JobFilterOption>> loadOptions(
    JobFilterOptionsSource source,
    String search,
  ) {
    final language = CacheHelper.getData(key: 'LOCALE')?.toString() ?? 'en';
    return repo.getRemoteOptions(source, search, language);
  }

  Map<String, dynamic> buildQuery({required int page}) {
    final query = <String, dynamic>{'page': page, 'per_page': 15};
    if (state.search.trim().isNotEmpty) query['search'] = state.search.trim();
    state.filters.forEach((key, value) {
      if (value != null && '$value'.isNotEmpty) query[key] = value;
    });
    final selectedSort = state.tab == ExploreTab.latest
        ? state.schema?.sortOptions
                  .where((option) => option.key == 'newest')
                  .firstOrNull ??
              state.sort
        : state.sort;
    selectedSort?.parameters.forEach((key, value) => query[key] = value);
    return query;
  }

  Future<void> load({bool refresh = false}) async {
    if (state.loading || state.loadingMore) return;
    if (state.tab == ExploreTab.forYou) {
      if (!state.isAuthenticated) return;
      if (!refresh && state.forYou.isNotEmpty) return;
      emit(state.copyWith(loading: true, clearError: true));
      try {
        emit(
          state.copyWith(forYou: await repo.getRecommended(), loading: false),
        );
      } catch (error) {
        emit(state.copyWith(loading: false, error: error.toString()));
      }
      return;
    }
    final currentPage = state.tab == ExploreTab.latest
        ? state.latestPage
        : state.allPage;
    final page = refresh ? 1 : currentPage + 1;
    if (!refresh && !state.hasMore) return;
    emit(
      state.copyWith(loading: refresh, loadingMore: !refresh, clearError: true),
    );
    try {
      final result = await repo.getJobs(buildQuery(page: page));
      final existing = refresh ? <JobModel>[] : state.visibleJobs;
      final byId = <int, JobModel>{
        for (final job in [...existing, ...result.jobs]) job.id: job,
      };
      if (state.tab == ExploreTab.latest) {
        emit(
          state.copyWith(
            latest: byId.values.toList(),
            latestPage: result.currentPage,
            latestHasMore: result.hasMore,
            loading: false,
            loadingMore: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            all: byId.values.toList(),
            allPage: result.currentPage,
            allHasMore: result.hasMore,
            loading: false,
            loadingMore: false,
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          error: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
