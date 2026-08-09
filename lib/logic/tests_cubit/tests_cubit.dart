import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/tests_repo.dart';
import 'tests_state.dart';

class TestsCubit extends Cubit<TestsStates> {
  final TestsRepo testsRepo;
  TestsCubit(this.testsRepo) : super(TestsInitialState());

  static TestsCubit get(context) => BlocProvider.of(context);

  void getTests() {
    emit(TestsLoadingState());
    testsRepo.getTests().then((list) {
      emit(GetTestsSuccessState(list));
    }).catchError((error) {
      emit(TestsErrorState(error.toString()));
    });
  }

  void getMyTests() {
    emit(TestsLoadingState());
    testsRepo.getMyTests().then((list) {
      emit(GetTestsSuccessState(list));
    }).catchError((error) {
      emit(TestsErrorState(error.toString()));
    });
  }

  void getTestDetails(int id) {
    emit(TestsLoadingState());
    testsRepo.getTestDetails(id).then((test) {
      if (test.id != -1) {
        emit(GetTestDetailsSuccessState(test));
      } else {
        emit(TestsErrorState(test.message ?? 'Failed to load test'));
      }
    }).catchError((error) {
      emit(TestsErrorState(error.toString()));
    });
  }
}
