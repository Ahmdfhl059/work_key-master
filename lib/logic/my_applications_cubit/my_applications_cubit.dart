import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/applications_response_model.dart';
import 'package:work_key/data/repo/application_repo.dart';
import 'my_applications_state.dart';

class MyApplicationsCubit extends Cubit<MyApplicationsState> {
  final ApplicationRepo repo;
  Timer? _debounce;
  int _requestVersion = 0;
  MyApplicationsCubit(this.repo) : super(const MyApplicationsState());

  Future<void> initialize() => load(refresh: true);

  Future<void> selectGroup(String group) async {
    if (group == state.group) return;
    _requestVersion++;
    emit(
      state.copyWith(
        group: group,
        items: [],
        page: 1,
        lastPage: 1,
        clearError: true,
      ),
    );
    await load(refresh: true);
  }

  void setSearch(String search) {
    _debounce?.cancel();
    emit(state.copyWith(search: search));
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => load(refresh: true),
    );
  }

  Future<void> applyFilters({
    required List<String> statuses,
    required String sortBy,
    required String direction,
  }) async {
    _requestVersion++;
    emit(
      state.copyWith(
        statuses: statuses,
        sortBy: sortBy,
        sortDirection: direction,
        items: [],
      ),
    );
    await load(refresh: true);
  }

  Map<String, dynamic> buildQuery(int page) => {
    'group': state.group,
    'sort_by': state.sortBy,
    'sort_direction': state.sortDirection,
    'per_page': 15,
    'page': page,
    if (state.search.trim().isNotEmpty) 'search': state.search.trim(),
    if (state.statuses.isNotEmpty) 'status[]': state.statuses,
  };

  Future<void> load({bool refresh = false}) async {
    if (state.loading || state.loadingMore || (!refresh && !state.hasMore))
      return;
    final version = ++_requestVersion;
    final page = refresh ? 1 : state.page + 1;
    emit(
      state.copyWith(
        loading: refresh,
        loadingMore: !refresh,
        clearError: true,
        items: refresh ? [] : state.items,
      ),
    );
    try {
      final response = await repo.getMyApplicationsPage(buildQuery(page));
      if (version != _requestVersion) return;
      final existing = refresh ? <JobApplication>[] : state.items;
      final merged = <int, JobApplication>{
        for (final item in [...existing, ...response.items]) item.id: item,
      };
      emit(
        state.copyWith(
          items: merged.values.toList(),
          counts: response.meta.counts,
          page: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          loading: false,
          loadingMore: false,
        ),
      );
    } catch (_) {
      if (version == _requestVersion)
        emit(
          state.copyWith(
            loading: false,
            loadingMore: false,
            error: 'Unable to load your applications. Please try again.',
          ),
        );
    }
  }

  Future<void> withdraw(int id, {String? reason}) async {
    await repo.withdrawTypedApplication(id, reason: reason);
    await load(refresh: true);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
