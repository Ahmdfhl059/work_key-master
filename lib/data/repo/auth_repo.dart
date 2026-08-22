import 'dart:async';

import 'package:dio/dio.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';
import '../../utils/shared%20preferences.dart';
import '../../services/push_notification_service.dart';

class AuthRepo {
  final AuthApi _authApi = AuthApi();

  Future<UserModel> login(Map<String, dynamic> data) async {
    print('--- AuthRepo: Attempting Login ---');
    print('Payload: $data');
    try {
      Response response = await _authApi.login(data);
      print('--- AuthRepo: Received Response ---');
      print('Status Code: ${response.statusCode}');
      print('Data: ${response.data}');

      Map<String, dynamic> responseData = response.data;

      if (responseData['success'] == true) {
        String token = responseData['data']['token'];
        UserModel user = UserModel.fromMap(responseData['data']['user']);
        user.message = responseData['message'];
        if (user.emailVerified) {
          print('Login Success. Token received.');
          await CacheHelper.saveData(key: 'token', value: token);
          unawaited(PushNotificationService.instance.syncTokenWithBackend());
        } else {
          await CacheHelper.removeData(key: 'token');
        }
        return user;
      } else {
        print('Login Failed: ${responseData['message']}');
        UserModel errorUser = UserModel.initial();
        errorUser.message = responseData['message'];
        return errorUser;
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      final root = data is Map
          ? Map<String, dynamic>.from(data)
          : const <String, dynamic>{};
      final code = root['code']?.toString().toUpperCase();
      if (code == 'EMAIL_NOT_VERIFIED') {
        final user = UserModel.initial();
        user.message = 'EMAIL_NOT_VERIFIED';
        return user;
      }
      print('--- AuthRepo: Error Caught ---');
      print('Error: ${root['message'] ?? error.message}');
      final user = UserModel.initial();
      user.message = root['message']?.toString() ?? error.message;
      return user;
    } catch (e) {
      print('--- AuthRepo: Error Caught ---');
      print('Error: $e');
      UserModel errorUser = UserModel.initial();
      errorUser.message = e.toString();
      return errorUser;
    }
  }

  Future<UserModel> registerJobSeeker(Map<String, dynamic> data) async {
    print('--- AuthRepo: Attempting Register ---');
    print('Payload: $data');
    try {
      Response response = await _authApi.registerJobSeeker({
        ...data,
        'terms_accepted': true,
      });
      print('--- AuthRepo: Received Response ---');
      print('Status Code: ${response.statusCode}');
      print('Data: ${response.data}');

      Map<String, dynamic> responseData = response.data;

      if (responseData['success'] == true || response.statusCode == 201) {
        print('Register Success');
        UserModel user = UserModel.fromMap(
          responseData['data']?['user'] ?? responseData['data'],
        );
        user.message = responseData['message'];
        final token = responseData['data']?['token'];
        if (token != null && user.emailVerified) {
          await CacheHelper.saveData(key: 'token', value: token);
          unawaited(PushNotificationService.instance.syncTokenWithBackend());
        } else {
          await CacheHelper.removeData(key: 'token');
        }
        return user;
      } else {
        print('Register Failed: ${responseData['message']}');
        UserModel errorUser = UserModel.initial();
        errorUser.message = responseData['message'];
        return errorUser;
      }
    } catch (e) {
      print('--- AuthRepo: Error Caught ---');
      print('Error: $e');
      UserModel errorUser = UserModel.initial();
      errorUser.message = e.toString();
      return errorUser;
    }
  }

  Future<String> resendAccountVerification({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.resendEmailOtp(email);
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] != true) {
      throw StateError(
        root['message']?.toString() ?? 'Could not resend verification code',
      );
    }
    return root['message']?.toString() ?? 'A new code was sent';
  }

  Future<String> verifyAccountEmail({
    required String email,
    required String otp,
  }) async {
    final response = await _authApi.verifyEmailOtp(email, otp);
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] != true) {
      throw StateError(
        root['message']?.toString() ?? 'Invalid verification code',
      );
    }
    return root['message']?.toString() ?? 'Email verified';
  }

  Future<String> forgotPassword(String email) async {
    print('--- AuthRepo: Forgot Password for $email ---');
    try {
      Response response = await _authApi.forgotPassword(email);
      print('Response: ${response.data}');
      final root = Map<String, dynamic>.from(response.data as Map);
      if (root['success'] != true) {
        throw StateError(root['message']?.toString() ?? 'Request failed');
      }
      return root['message']?.toString() ?? 'Check your email';
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> resetPassword(Map<String, dynamic> data) async {
    print('--- AuthRepo: Attempting Reset Password ---');
    try {
      Response response = await _authApi.resetPassword(data);
      print('Response: ${response.data}');
      final root = Map<String, dynamic>.from(response.data as Map);
      if (root['success'] != true) {
        throw StateError(
          root['message']?.toString() ?? 'Password reset failed',
        );
      }
      return root['message']?.toString() ?? 'Success';
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<UserModel> getMe() async {
    print('--- AuthRepo: Fetching My Data ---');
    try {
      Response response = await _authApi.getMe();
      if (response.data['success'] == true) {
        return UserModel.fromMap(response.data['data']);
      }
      return UserModel.initial();
    } catch (e) {
      print('Error: $e');
      return UserModel.initial();
    }
  }

  Future<String> logout() async {
    print('--- AuthRepo: Logging out ---');
    try {
      await PushNotificationService.instance.unregisterCurrentDevice();
      Response response = await _authApi.logout();
      await CacheHelper.removeData(key: 'token');
      return response.data['message'] ?? 'Logged out';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> logoutAll() async {
    await PushNotificationService.instance.unregisterCurrentDevice();
    final response = await _authApi.logoutAll();
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] == false) {
      throw StateError(root['message']?.toString() ?? 'Logout failed');
    }
    await CacheHelper.removeData(key: 'token');
    return root['message']?.toString() ?? 'Logged out everywhere';
  }
}
