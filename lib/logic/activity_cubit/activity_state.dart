import 'package:work_key/data/models/activity_response_model.dart';

class ActivityState {
  final String group, search, sortBy, sortDirection;
  final List<String> types;
  final DateTime? dateFrom, dateTo;
  final ActivitySummary summary;
  final List<ActivityItem> required, schedule, feed;
  final int page, lastPage;
  final bool loading, loadingMore, refreshing, markingRead;
  final String? error, paginationError;

  const ActivityState({this.group = 'all', this.search = '', this.sortBy = 'priority', this.sortDirection = 'desc', this.types = const [], this.dateFrom, this.dateTo, this.summary = const ActivitySummary(), this.required = const [], this.schedule = const [], this.feed = const [], this.page = 1, this.lastPage = 1, this.loading = false, this.loadingMore = false, this.refreshing = false, this.markingRead = false, this.error, this.paginationError});
  bool get hasMore => page < lastPage;
  int get activeFilterCount => types.length + (dateFrom == null ? 0 : 1) + (dateTo == null ? 0 : 1) + (sortBy == 'priority' && sortDirection == 'desc' ? 0 : 1);

  ActivityState copyWith({String? group, String? search, String? sortBy, String? sortDirection, List<String>? types, DateTime? dateFrom, DateTime? dateTo, bool clearDates = false, ActivitySummary? summary, List<ActivityItem>? required, List<ActivityItem>? schedule, List<ActivityItem>? feed, int? page, int? lastPage, bool? loading, bool? loadingMore, bool? refreshing, bool? markingRead, String? error, String? paginationError, bool clearErrors = false}) => ActivityState(
    group: group ?? this.group, search: search ?? this.search, sortBy: sortBy ?? this.sortBy, sortDirection: sortDirection ?? this.sortDirection, types: types ?? this.types,
    dateFrom: clearDates ? null : dateFrom ?? this.dateFrom, dateTo: clearDates ? null : dateTo ?? this.dateTo,
    summary: summary ?? this.summary, required: required ?? this.required, schedule: schedule ?? this.schedule, feed: feed ?? this.feed, page: page ?? this.page, lastPage: lastPage ?? this.lastPage,
    loading: loading ?? this.loading, loadingMore: loadingMore ?? this.loadingMore, refreshing: refreshing ?? this.refreshing, markingRead: markingRead ?? this.markingRead,
    error: clearErrors ? null : error ?? this.error, paginationError: clearErrors ? null : paginationError ?? this.paginationError,
  );
}
