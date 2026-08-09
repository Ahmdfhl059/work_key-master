import 'package:work_key/data/models/applications_response_model.dart';

class MyApplicationsState {
  final String group;
  final List<JobApplication> items;
  final ApplicationCounts counts;
  final int page;
  final int lastPage;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final String search;
  final List<String> statuses;
  final String sortBy;
  final String sortDirection;

  const MyApplicationsState({this.group = 'all', this.items = const [], this.counts = const ApplicationCounts(), this.page = 1, this.lastPage = 1, this.loading = false, this.loadingMore = false, this.error, this.search = '', this.statuses = const [], this.sortBy = 'priority', this.sortDirection = 'desc'});
  bool get hasMore => page < lastPage;

  MyApplicationsState copyWith({String? group, List<JobApplication>? items, ApplicationCounts? counts, int? page, int? lastPage, bool? loading, bool? loadingMore, String? error, String? search, List<String>? statuses, String? sortBy, String? sortDirection, bool clearError = false}) => MyApplicationsState(
    group: group ?? this.group, items: items ?? this.items, counts: counts ?? this.counts, page: page ?? this.page, lastPage: lastPage ?? this.lastPage,
    loading: loading ?? this.loading, loadingMore: loadingMore ?? this.loadingMore, error: clearError ? null : error ?? this.error, search: search ?? this.search,
    statuses: statuses ?? this.statuses, sortBy: sortBy ?? this.sortBy, sortDirection: sortDirection ?? this.sortDirection,
  );
}
