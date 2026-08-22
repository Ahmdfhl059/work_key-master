import 'package:dio/dio.dart';
import 'package:work_key/utils/dio_methods.dart';

class ActivityApi {
  Future<Response> getActivity(Map<String, dynamic> query) =>
      RemoteApi.get('/activity', queryParameters: query);
  Future<Response> markRead(int id) =>
      RemoteApi.patch('/notifications/$id/read');
  Future<Response> markAllRead() => RemoteApi.patch('/notifications/read-all');
}
