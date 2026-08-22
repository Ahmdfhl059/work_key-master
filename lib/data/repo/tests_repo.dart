import 'package:dio/dio.dart';
import '../api/tests_api.dart';
import '../models/test_model.dart';
import '../models/test_assignment_model.dart';

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

  Future<List<TestAssignmentModel>> getMyTests() async {
    final response = await _testsApi.getMyTests();
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true)
      throw StateError(root['message']?.toString() ?? 'Could not load tests');
    final data = root['data'];
    final list = data is List
        ? data
        : data is Map && data['data'] is List
        ? data['data'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => TestAssignmentModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> startTest(int assignmentId) async {
    final response = await _testsApi.startTest(assignmentId);
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true)
      throw StateError(root['message']?.toString() ?? 'Could not start test');
    final attempt = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'])
        : <String, dynamic>{};
    final attemptId = int.tryParse('${attempt['id'] ?? attempt['attempt_id']}');
    if (attemptId == null) {
      throw StateError('The server did not return a test attempt id');
    }
    final questionsResponse = await _testsApi.getAttemptQuestions(attemptId);
    final questionsRoot = questionsResponse.data is Map
        ? Map<String, dynamic>.from(questionsResponse.data)
        : <String, dynamic>{};
    final questionsData = questionsRoot['data'];
    attempt['questions'] = questionsData is List
        ? questionsData
        : questionsData is Map && questionsData['data'] is List
        ? questionsData['data']
        : const [];
    return attempt;
  }

  Future<String> submitTest(
    int assignmentId,
    int attemptId,
    List<Map<String, dynamic>> answers,
  ) async {
    if (answers.isNotEmpty) await _testsApi.saveAnswers(attemptId, answers);
    final response = await _testsApi.submitTest(assignmentId, answers);
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true)
      throw StateError(root['message']?.toString() ?? 'Could not submit test');
    return root['message']?.toString() ?? 'Test submitted';
  }

  Future<String> forfeitTest(
    int assignmentId, {
    String reason = 'app_backgrounded',
  }) async {
    final response = await _testsApi.forfeitTest(assignmentId, reason: reason);
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true) {
      throw StateError(root['message']?.toString() ?? 'Could not forfeit test');
    }
    return root['message']?.toString() ?? 'Test forfeited';
  }

  Future<void> uploadFileAnswer(
    int attemptId,
    int questionId,
    String path,
    String name,
  ) async {
    final response = await _testsApi.uploadFileAnswer(
      attemptId,
      questionId,
      await MultipartFile.fromFile(path, filename: name),
    );
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true) {
      throw StateError(root['message']?.toString() ?? 'File upload failed');
    }
  }

  Future<Map<String, dynamic>> getAttemptResult(int attemptId) async {
    final response = await _testsApi.getAttemptResult(attemptId);
    return _requiredMap(response, 'Could not load test result');
  }

  Future<Map<String, dynamic>> getAttemptSeries(int assignmentId) async {
    final response = await _testsApi.getAttemptSeries(assignmentId);
    return _requiredMap(response, 'Could not load test attempts');
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

  Map<String, dynamic> _requiredMap(Response response, String fallback) {
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true) {
      throw StateError(root['message']?.toString() ?? fallback);
    }
    final data = root['data'];
    return data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'items': data is List ? data : const []};
  }
}
