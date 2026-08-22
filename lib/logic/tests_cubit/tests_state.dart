import '../../data/models/test_model.dart';
import '../../data/models/test_assignment_model.dart';

abstract class TestsStates {}

class TestsInitialState extends TestsStates {}

class TestsLoadingState extends TestsStates {}

class GetTestsSuccessState extends TestsStates {
  final List<TestModel> tests;
  GetTestsSuccessState(this.tests);
}

class GetAssignedTestsSuccessState extends TestsStates {
  final List<TestAssignmentModel> assignments;
  GetAssignedTestsSuccessState(this.assignments);
}

class TestStartedState extends TestsStates {
  final TestAssignmentModel assignment;
  final Map<String, dynamic> attempt;
  TestStartedState(this.assignment, this.attempt);
}

class TestSubmittedState extends TestsStates {
  final String message;
  TestSubmittedState(this.message);
}

class GetTestDetailsSuccessState extends TestsStates {
  final TestModel testModel;
  GetTestDetailsSuccessState(this.testModel);
}

class TestsErrorState extends TestsStates {
  final String error;
  TestsErrorState(this.error);
}
