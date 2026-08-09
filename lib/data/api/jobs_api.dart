import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class JobsApi {
  Future<Response> getJobs({Map<String, dynamic>? query}) async {
    return await RemoteApi.get('jobs', queryParameters: query);
  }

  Future<Response> getJobDetails(int id) async {
    return await RemoteApi.get('jobs/$id');
  }

  Future<Response> getRecommendedJobs({int limit = 20}) async {
    return await RemoteApi.get('jobs/recommended', queryParameters: {'limit': limit});
  }

  Future<Response> getFilterSchema({required String language}) async {
    return await RemoteApi.get(
      'reference/job-filters',
      headers: {'Accept': 'application/json', 'Accept-Language': language},
    );
  }

  Future<Response> getRemoteOptions(
    String endpoint, {
    required String searchParameter,
    required String search,
    required String language,
  }) async {
    return await RemoteApi.get(
      endpoint,
      headers: {'Accept': 'application/json', 'Accept-Language': language},
      queryParameters: {if (search.isNotEmpty) searchParameter: search},
    );
  }

  Future<Response> getMyJobs() async {
    return await RemoteApi.get('jobs/my');
  }

  Future<Response> postJob(Map<String, dynamic> data) async {
    return await RemoteApi.post('jobs', body: data);
  }

  Future<Response> updateJob(int id, Map<String, dynamic> data) async {
    return await RemoteApi.put('jobs/$id', body: data);
  }

  Future<Response> deleteJob(int id) async {
    return await RemoteApi.delete('jobs/$id');
  }

  Future<Response> publishJob(int id) async {
    return await RemoteApi.post('jobs/$id/publish');
  }

  Future<Response> closeJob(int id) async {
    return await RemoteApi.post('jobs/$id/close');
  }
}
