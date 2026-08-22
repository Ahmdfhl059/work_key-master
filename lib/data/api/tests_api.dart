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

  Future<Response> getAttemptQuestions(int attemptId) =>
      RemoteApi.get('/test-attempts/$attemptId/questions');

  Future<Response> getAttemptAnswers(int attemptId) =>
      RemoteApi.get('/test-attempts/$attemptId/answers');

  Future<Response> getAttemptResult(int attemptId) =>
      RemoteApi.get('/test-attempts/$attemptId/result');

  Future<Response> getAttemptSeries(int assignmentId) =>
      RemoteApi.get('/test-assignments/$assignmentId/attempt-series');

  Future<Response> saveAnswers(
    int attemptId,
    List<Map<String, dynamic>> answers,
  ) => RemoteApi.post(
    '/test-attempts/$attemptId/answers/bulk',
    body: {'answers': answers},
  );

  Future<Response> uploadFileAnswer(
    int attemptId,
    int questionId,
    MultipartFile file,
  ) => RemoteApi.post(
    '/test-attempts/$attemptId/answers/$questionId/file',
    body: FormData.fromMap({'answer_file': file}),
  );

  Future<Response> submitTest(
    int assignmentId,
    List<Map<String, dynamic>> answers,
  ) async {
    // Answers are saved against the attempt first. Submission only confirms
    // that the assignment should be finalized.
    return await RemoteApi.post(
      '/tests/$assignmentId/submit',
      body: {'confirm': true},
    );
  }

  Future<Response> forfeitTest(
    int assignmentId, {
    String reason = 'app_backgrounded',
  }) =>
      RemoteApi.post('/tests/$assignmentId/forfeit', body: {'reason': reason});

  // Employer specific
  Future<Response> assignTest(int applicationId, int testId) async {
    return await RemoteApi.post(
      '/applications/$applicationId/assign-test',
      body: {'test_id': testId},
    );
  }

  Future<Response> evaluateTest(
    int attemptId,
    int score,
    String? feedback,
  ) async {
    return await RemoteApi.post(
      '/tests/$attemptId/evaluate',
      body: {'score': score, 'feedback': feedback},
    );
  }
}
