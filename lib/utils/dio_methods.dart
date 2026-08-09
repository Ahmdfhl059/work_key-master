import 'dart:convert';
import 'package:dio/dio.dart';
import 'constants.dart';
import 'headers.dart';
import 'dio_error_handler.dart';
import 'shared preferences.dart';

class RemoteApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseURL.endsWith('/') ? baseURL : '$baseURL/',
      headers: headersWithContent,
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static Future<Response> _makeRequest(
    String method,
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool preserveDioError = false,
  }) async {
    // تنظيف المسار لضمان عدم تكرار السلاش
    String cleanPath = url.startsWith('/') ? url.substring(1) : url;
    
    print('--- 🚀 Request Start ---');
    print('Full URL: ${_dio.options.baseUrl}$cleanPath');
    print('Method: $method');
    if (body != null) print('Payload: $body');

    try {
      String? token = CacheHelper.getData(key: 'token');
      
      // لا نرسل التوكن في طلبات الدخول والتسجيل
      bool isAuthRequest = cleanPath.contains('auth/login') || cleanPath.contains('auth/register');
      
      Map<String, String> finalHeaders;
      if (isAuthRequest) {
        finalHeaders = headersWithContent;
      } else {
        finalHeaders = headers ?? (token != null ? headersWithAuthContent(token) : headersWithContent);
      }
      finalHeaders = {
        ...finalHeaders,
        'Accept-Language': CacheHelper.getData(key: 'LOCALE')?.toString() ?? 'en',
      };

      final response = await _dio.request(
        cleanPath,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: finalHeaders,
        ),
      );
      
      print('--- ✅ Success Response: ${response.statusCode} ---');
      return response;
    } on DioException catch (e) {
      print('--- ❌ Server Error ---');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
      }
      if (preserveDioError) rethrow;
      throw DioErrorHandler.handle(e);
    } catch (e) {
      print('--- ⚠️ System Error: $e ---');
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  static Future<Response> post(String url, {dynamic body, Map<String, String>? headers}) async {
    return _makeRequest('POST', url, body: body, headers: headers);
  }

  static Future<Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool preserveDioError = false,
  }) async {
    return _makeRequest(
      'GET',
      url,
      headers: headers,
      queryParameters: queryParameters,
      preserveDioError: preserveDioError,
    );
  }

  static Future<Response> put(String url, {dynamic body, Map<String, String>? headers}) async {
    return _makeRequest('PUT', url, body: body, headers: headers);
  }

  static Future<Response> patch(String url, {dynamic body, Map<String, String>? headers}) async {
    return _makeRequest('PATCH', url, body: body, headers: headers);
  }

  static Future<Response> delete(String url, {Map<String, String>? headers}) async {
    return _makeRequest('DELETE', url, headers: headers);
  }
}
