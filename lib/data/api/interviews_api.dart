import 'package:dio/dio.dart';

import '../../utils/dio_methods.dart';

class InterviewsApi {
  Future<Response> getMyInterviews({int page = 1, int perPage = 15}) =>
      RemoteApi.get(
        '/my/interviews',
        queryParameters: {'page': page, 'per_page': perPage},
      );

  Future<Response> getInterviewDetails(int id) =>
      RemoteApi.get('/interviews/$id');

  Future<Response> confirmInterview(int id) =>
      RemoteApi.post('/interviews/$id/confirm');

  Future<Response> createVideoSession(int id) =>
      RemoteApi.post('/interviews/$id/video-session');

  // Employer endpoints are kept for the existing employer-side flows.
  Future<Response> scheduleInterview(
    int applicationId,
    Map<String, dynamic> data,
  ) => RemoteApi.post('/applications/$applicationId/interviews', body: data);

  Future<Response> updateInterview(int id, Map<String, dynamic> data) =>
      RemoteApi.put('/interviews/$id', body: data);

  Future<Response> completeInterview(int id, String? note) => RemoteApi.post(
    '/interviews/$id/complete',
    body: {'completion_note': note},
  );

  Future<Response> evaluateInterview(int id, Map<String, dynamic> data) =>
      RemoteApi.post('/interviews/$id/evaluate', body: data);
}
