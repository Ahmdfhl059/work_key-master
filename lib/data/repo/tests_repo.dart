import 'package:dio/dio.dart';
import '../api/tests_api.dart';
import '../models/test_model.dart';

class TestsRepo {
  final TestsApi _testsApi = TestsApi();

  Future<List<TestModel>> getTests() async {
    try {
      Response response = await _testsApi.getTests();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => TestModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<TestModel>> getMyTests() async {
    try {
      Response response = await _testsApi.getMyTests();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => TestModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<TestModel> getTestDetails(int id) async {
    try {
      Response response = await _testsApi.getTestDetails(id);
      if (response.data['success'] == true) {
        TestModel test = TestModel.fromMap(response.data['data']);
        test.message = response.data['message'];
        return test;
      } else {
        TestModel error = TestModel.initial();
        error.message = response.data['message'];
        return error;
      }
    } catch (e) {
      TestModel error = TestModel.initial();
      error.message = e.toString();
      return error;
    }
  }
}
