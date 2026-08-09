import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class AuthApi {
  Future<Response> login(Map<String, dynamic> data) async {
    return await RemoteApi.post('auth/login', body: data);
  }

  Future<Response> registerJobSeeker(Map<String, dynamic> data) async {
    return await RemoteApi.post('auth/register/job-seeker', body: data);
  }

  Future<Response> getMe() async {
    return await RemoteApi.get('auth/me');
  }

  Future<Response> forgotPassword(String email) async {
    return await RemoteApi.post('auth/forgot-password', body: {'email': email});
  }

  Future<Response> resetPassword(Map<String, dynamic> data) async {
    return await RemoteApi.post('auth/reset-password', body: data);
  }

  Future<Response> changePassword(Map<String, dynamic> data) async {
    return await RemoteApi.post('auth/change-password', body: data);
  }

  Future<Response> logout() async {
    return await RemoteApi.post('auth/logout');
  }
}
