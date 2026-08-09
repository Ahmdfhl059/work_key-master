import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class TestsApi {
  Future<Response> getTests() async {
    return await RemoteApi.get('/tests');
  }

  Future<Response> getMyTests() async {
    return await RemoteApi.get('/my/tests');
  }

  Future<Response> getTestDetails(int id) async {
    return await RemoteApi.get('/tests/$id');
  }

  Future<Response> startTest(int assignmentId) async {
    return await RemoteApi.post('/tests/$assignmentId/start');
  }

  Future<Response> submitTest(int assignmentId, List<Map<String, dynamic>> answers) async {
    return await RemoteApi.post('/tests/$assignmentId/submit', body: {'answers': answers});
  }

  // Employer specific
  Future<Response> assignTest(int applicationId, int testId) async {
    return await RemoteApi.post('/applications/$applicationId/assign-test', body: {'test_id': testId});
  }

  Future<Response> evaluateTest(int attemptId, int score, String? feedback) async {
    return await RemoteApi.post('/tests/$attemptId/evaluate', body: {'score': score, 'feedback': feedback});
  }
}
