import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/interview_model.dart';
import '../../data/repo/interviews_repo.dart';
import 'interviews_state.dart';

class InterviewsCubit extends Cubit<InterviewsState> {
  final InterviewsRepo interviewsRepo;
  bool _requestInFlight = false;

  InterviewsCubit(this.interviewsRepo) : super(const InterviewsState());

  static InterviewsCubit get(context) => BlocProvider.of(context);

  Future<void> initialize() => load(refresh: true);

  Future<void> load({bool refresh = false}) async {
    if (_requestInFlight || (!refresh && !state.hasMore)) return;
    _requestInFlight = true;
    final targetPage = refresh ? 1 : state.page + 1;
    emit(
      state.copyWith(
        loading: refresh && state.items.isEmpty,
        refreshing: refresh && state.items.isNotEmpty,
        loadingMore: !refresh,
        clearErrors: true,
      ),
    );

    try {
      final response = await interviewsRepo.getMyInterviews(page: targetPage);
      final items = refresh
          ? response.items
          : _mergeById(state.items, response.items);
      emit(
        state.copyWith(
          items: items,
          page: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          total: response.meta.total,
          loading: false,
          loadingMore: false,
          refreshing: false,
          clearErrors: true,
        ),
      );
    } catch (_) {
      const message = 'We could not load your interviews. Please try again.';
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          refreshing: false,
          error: state.items.isEmpty ? message : null,
          paginationError: state.items.isEmpty ? null : message,
        ),
      );
    } finally {
      _requestInFlight = false;
    }
  }

  void updateInterview(InterviewModel interview) {
    emit(
      state.copyWith(
        items: state.items
            .map((item) => item.id == interview.id ? interview : item)
            .toList(),
      ),
    );
  }

  List<InterviewModel> _mergeById(
    List<InterviewModel> current,
    List<InterviewModel> next,
  ) {
    final result = [...current];
    final existingIds = current.map((item) => item.id).toSet();
    result.addAll(next.where((item) => existingIds.add(item.id)));
    return result;
  }
}
