import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class InterviewsApi {
  Future<Response> getMyInterviews() async {
    return await RemoteApi.get('/my/interviews');
  }

  Future<Response> getInterviewDetails(int id) async {
    return await RemoteApi.get('/interviews/$id');
  }

  // Employer specific
  Future<Response> scheduleInterview(int applicationId, Map<String, dynamic> data) async {
    return await RemoteApi.post('/applications/$applicationId/interviews', body: data);
  }

  Future<Response> updateInterview(int id, Map<String, dynamic> data) async {
    return await RemoteApi.put('/interviews/$id', body: data);
  }

  Future<Response> completeInterview(int id, String? note) async {
    return await RemoteApi.post('/interviews/$id/complete', body: {'completion_note': note});
  }

  Future<Response> evaluateInterview(int id, Map<String, dynamic> data) async {
    return await RemoteApi.post('/interviews/$id/evaluate', body: data);
  }
}
