import 'package:dio/dio.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';
import '../../utils/shared%20preferences.dart';

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
        print('Login Success. Token: $token');
        await CacheHelper.saveData(key: 'token', value: token);
        
        UserModel user = UserModel.fromMap(responseData['data']['user']);
        user.message = responseData['message'];
        return user;
      } else {
        print('Login Failed: ${responseData['message']}');
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
        if (responseData['data'] != null && responseData['data']['token'] != null) {
            await CacheHelper.saveData(key: 'token', value: responseData['data']['token']);
        }
        
        UserModel user = UserModel.fromMap(responseData['data']?['user'] ?? responseData['data']);
        user.message = responseData['message'];
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

  Future<String> forgotPassword(String email) async {
    print('--- AuthRepo: Forgot Password for $email ---');
    try {
      Response response = await _authApi.forgotPassword(email);
      print('Response: ${response.data}');
      return response.data['message'] ?? 'Check your email';
    } catch (e) {
      print('Error: $e');
      return e.toString();
    }
  }

  Future<String> resetPassword(Map<String, dynamic> data) async {
    print('--- AuthRepo: Attempting Reset Password ---');
    try {
      Response response = await _authApi.resetPassword(data);
      print('Response: ${response.data}');
      return response.data['message'] ?? 'Success';
    } catch (e) {
      print('Error: $e');
      return e.toString();
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
      Response response = await _authApi.logout();
      await CacheHelper.removeData(key: 'token');
      return response.data['message'] ?? 'Logged out';
    } catch (e) {
      return e.toString();
    }
  }
}
