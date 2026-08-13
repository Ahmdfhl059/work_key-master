import '../../data/models/interview_model.dart';

class InterviewsState {
  final List<InterviewModel> items;
  final int page;
  final int lastPage;
  final int total;
  final bool loading;
  final bool loadingMore;
  final bool refreshing;
  final String? error;
  final String? paginationError;

  const InterviewsState({
    this.items = const [],
    this.page = 1,
    this.lastPage = 1,
    this.total = 0,
    this.loading = false,
    this.loadingMore = false,
    this.refreshing = false,
    this.error,
    this.paginationError,
  });

  bool get hasMore => page < lastPage;

  InterviewsState copyWith({
    List<InterviewModel>? items,
    int? page,
    int? lastPage,
    int? total,
    bool? loading,
    bool? loadingMore,
    bool? refreshing,
    String? error,
    String? paginationError,
    bool clearErrors = false,
  }) => InterviewsState(
    items: items ?? this.items,
    page: page ?? this.page,
    lastPage: lastPage ?? this.lastPage,
    total: total ?? this.total,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    refreshing: refreshing ?? this.refreshing,
    error: clearErrors ? null : error ?? this.error,
    paginationError: clearErrors
        ? null
        : paginationError ?? this.paginationError,
  );
}
