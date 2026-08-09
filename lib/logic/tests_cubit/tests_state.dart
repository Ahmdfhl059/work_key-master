import '../../data/models/test_model.dart';

abstract class TestsStates {}

class TestsInitialState extends TestsStates {}

class TestsLoadingState extends TestsStates {}

class GetTestsSuccessState extends TestsStates {
  final List<TestModel> tests;
  GetTestsSuccessState(this.tests);
}

class GetTestDetailsSuccessState extends TestsStates {
  final TestModel testModel;
  GetTestDetailsSuccessState(this.testModel);
}

class TestsErrorState extends TestsStates {
  final String error;
  TestsErrorState(this.error);
}
