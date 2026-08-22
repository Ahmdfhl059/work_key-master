import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/tests_repo.dart';
import 'tests_state.dart';
import '../../data/models/test_assignment_model.dart';

class TestsCubit extends Cubit<TestsStates> {
  final TestsRepo testsRepo;
  TestsCubit(this.testsRepo) : super(TestsInitialState());

  static TestsCubit get(context) => BlocProvider.of(context);

  void getTests() {
    emit(TestsLoadingState());
    testsRepo
        .getTests()
        .then((list) {
          emit(GetTestsSuccessState(list));
        })
        .catchError((error) {
          emit(TestsErrorState(error.toString()));
        });
  }

  Future<void> startTest(TestAssignmentModel assignment) async {
    emit(TestsLoadingState());
    try {
      final attempt = await testsRepo.startTest(assignment.id);
      emit(TestStartedState(assignment, attempt));
    } catch (error) {
      emit(TestsErrorState(error.toString()));
    }
  }

  Future<void> submitTest(
    int assignmentId,
    int attemptId,
    List<Map<String, dynamic>> answers,
  ) async {
    emit(TestsLoadingState());
    try {
      final message = await testsRepo.submitTest(
        assignmentId,
        attemptId,
        answers,
      );
      emit(TestSubmittedState(message));
    } catch (error) {
      emit(TestsErrorState(error.toString()));
    }
  }

  Future<void> forfeitTest(
    int assignmentId, {
    String reason = 'app_backgrounded',
  }) async {
    emit(TestsLoadingState());
    try {
      final message = await testsRepo.forfeitTest(assignmentId, reason: reason);
      emit(TestSubmittedState(message));
    } catch (error) {
      emit(TestsErrorState(error.toString()));
    }
  }

  Future<void> uploadFileAnswer(
    int attemptId,
    int questionId,
    String path,
    String name,
  ) => testsRepo.uploadFileAnswer(attemptId, questionId, path, name);

  void getMyTests() {
    emit(TestsLoadingState());
    testsRepo
        .getMyTests()
        .then((list) {
          emit(GetAssignedTestsSuccessState(list));
        })
        .catchError((error) {
          emit(TestsErrorState(error.toString()));
        });
  }

  void getTestDetails(int id) {
    emit(TestsLoadingState());
    testsRepo
        .getTestDetails(id)
        .then((test) {
          if (test.id != -1) {
            emit(GetTestDetailsSuccessState(test));
          } else {
            emit(TestsErrorState(test.message ?? 'Failed to load test'));
          }
        })
        .catchError((error) {
          emit(TestsErrorState(error.toString()));
        });
  }
}
