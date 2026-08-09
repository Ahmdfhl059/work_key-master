import 'package:work_key/data/models/job_filter_schema.dart';
import 'package:work_key/data/models/job_model.dart';

enum ExploreTab { forYou, latest, all }

class ExploreJobsState {
  final ExploreTab tab;
  final JobFilterSchema? schema;
  final bool schemaLoading;
  final String? schemaError;
  final List<JobModel> forYou;
  final List<JobModel> latest;
  final List<JobModel> all;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final int latestPage;
  final int allPage;
  final bool latestHasMore;
  final bool allHasMore;
  final String search;
  final Map<String, dynamic> filters;
  final JobSortOption? sort;
  final bool isAuthenticated;

  const ExploreJobsState({
    this.tab = ExploreTab.forYou,
    this.schema,
    this.schemaLoading = false,
    this.schemaError,
    this.forYou = const [],
    this.latest = const [],
    this.all = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.latestPage = 1,
    this.allPage = 1,
    this.latestHasMore = true,
    this.allHasMore = true,
    this.search = '',
    this.filters = const {},
    this.sort,
    this.isAuthenticated = false,
  });

  List<JobModel> get visibleJobs => tab == ExploreTab.forYou
      ? forYou
      : tab == ExploreTab.latest
      ? latest
      : all;
  bool get hasMore => tab == ExploreTab.latest
      ? latestHasMore
      : tab == ExploreTab.all && allHasMore;
  int get activeFilterCount => filters.values
      .where((value) => value != null && '$value'.isNotEmpty && value != false)
      .length;

  ExploreJobsState copyWith({
    ExploreTab? tab,
    JobFilterSchema? schema,
    bool? schemaLoading,
    String? schemaError,
    List<JobModel>? forYou,
    List<JobModel>? latest,
    List<JobModel>? all,
    bool? loading,
    bool? loadingMore,
    String? error,
    int? latestPage,
    int? allPage,
    bool? latestHasMore,
    bool? allHasMore,
    String? search,
    Map<String, dynamic>? filters,
    JobSortOption? sort,
    bool? isAuthenticated,
    bool clearError = false,
  }) => ExploreJobsState(
    tab: tab ?? this.tab,
    schema: schema ?? this.schema,
    schemaLoading: schemaLoading ?? this.schemaLoading,
    schemaError: schemaError ?? this.schemaError,
    forYou: forYou ?? this.forYou,
    latest: latest ?? this.latest,
    all: all ?? this.all,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
    latestPage: latestPage ?? this.latestPage,
    allPage: allPage ?? this.allPage,
    latestHasMore: latestHasMore ?? this.latestHasMore,
    allHasMore: allHasMore ?? this.allHasMore,
    search: search ?? this.search,
    filters: filters ?? this.filters,
    sort: sort ?? this.sort,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
  );
}
