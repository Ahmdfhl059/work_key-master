import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/activity_response_model.dart';
import 'package:work_key/data/repo/activity_repo.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo repo;
  Timer? _debounce;
  int _generation = 0;
  ActivityCubit(this.repo) : super(const ActivityState());

  Future<void> initialize() => load(refresh: true);
  Map<String, dynamic> _query(int page) => {
    'group': state.group, 'sort_by': state.sortBy, 'sort_direction': state.sortDirection, 'per_page': 15, 'page': page, 'schedule_limit': 5,
    'timezone': 'Asia/Damascus',
    if (state.search.trim().isNotEmpty) 'search': state.search.trim(),
    if (state.types.isNotEmpty) 'type[]': state.types,
    if (state.dateFrom != null) 'date_from': DateFormat('yyyy-MM-dd').format(state.dateFrom!),
    if (state.dateTo != null) 'date_to': DateFormat('yyyy-MM-dd').format(state.dateTo!),
  };

  Future<void> selectGroup(String group) async { if (group == state.group) return; emit(state.copyWith(group: group, feed: const [], page: 1, lastPage: 1, clearErrors: true)); await load(refresh: true); }
  void search(String value) { _debounce?.cancel(); emit(state.copyWith(search: value)); _debounce = Timer(const Duration(milliseconds: 400), () => load(refresh: true)); }
  Future<void> applyFilters({required List<String> types, required String sortBy, required String sortDirection, DateTime? from, DateTime? to, bool clearDates = false}) async { emit(state.copyWith(types: types, sortBy: sortBy, sortDirection: sortDirection, dateFrom: from, dateTo: to, clearDates: clearDates)); await load(refresh: true); }

  Future<void> load({bool refresh = false}) async {
    if (state.loading || state.loadingMore || state.refreshing) return;
    if (!refresh && !state.hasMore) return;
    final generation = refresh ? ++_generation : _generation;
    final page = refresh ? 1 : state.page + 1;
    emit(state.copyWith(loading: refresh && state.feed.isEmpty, refreshing: refresh && state.feed.isNotEmpty, loadingMore: !refresh, clearErrors: true));
    try {
      final response = await repo.getActivity(_query(page));
      if (generation != _generation) return;
      final combined = refresh ? response.feed.items : [...state.feed, ...response.feed.items];
      final unique = <String, ActivityItem>{};
      for (final item in combined) { unique[item.key.isEmpty ? '${item.type.key}-${item.occurredAt}-${unique.length}' : item.key] = item; }
      emit(state.copyWith(summary: response.summary, required: response.requiresAction, schedule: response.upcomingSchedule, feed: unique.values.toList(), page: response.feed.meta.currentPage, lastPage: response.feed.meta.lastPage, loading: false, refreshing: false, loadingMore: false));
    } catch (error) {
      emit(state.copyWith(loading: false, refreshing: false, loadingMore: false, error: refresh ? _message(error) : null, paginationError: refresh ? null : _message(error)));
    }
  }

  Future<void> openItem(ActivityItem item, Future<void> Function() navigate) async {
    if (!item.isRead && item.notificationId != null) {
      try { await repo.markRead(item.notificationId!); _markLocal(item.notificationId!); } catch (_) {}
    }
    await navigate();
  }
  Future<void> markAllRead() async { if (state.markingRead) return; emit(state.copyWith(markingRead: true)); try { await repo.markAllRead(); emit(state.copyWith(markingRead: false, summary: state.summary.copyWith(unreadNotifications: 0), feed: state.feed.map((e) => e.markRead()).toList())); } catch (error) { emit(state.copyWith(markingRead: false, error: _message(error))); } }
  void _markLocal(int id) => emit(state.copyWith(summary: state.summary.copyWith(unreadNotifications: state.summary.unreadNotifications > 0 ? state.summary.unreadNotifications - 1 : 0), feed: state.feed.map((item) => item.notificationId == id ? item.markRead() : item).toList()));
  String _message(Object error) => 'Unable to load activity. Please try again.';
  @override Future<void> close() { _debounce?.cancel(); return super.close(); }
}
