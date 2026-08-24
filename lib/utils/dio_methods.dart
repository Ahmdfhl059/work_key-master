import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    ResponseType? responseType,
  }) async {
    // تنظيف المسار لضمان عدم تكرار السلاش
    String cleanPath = url.startsWith('/') ? url.substring(1) : url;

    debugPrint('--- 🚀 Request Start ---');
    debugPrint('Full URL: ${_dio.options.baseUrl}$cleanPath');
    debugPrint('Method: $method');
    if (body != null) debugPrint('Payload: $body');

    try {
      String? token = CacheHelper.getData(key: 'token');

      // لا نرسل التوكن في طلبات الدخول والتسجيل
      bool isAuthRequest =
          cleanPath.contains('auth/login') ||
          cleanPath.contains('auth/register');

      Map<String, String> finalHeaders;
      if (isAuthRequest) {
        finalHeaders = headersWithContent;
      } else {
        finalHeaders =
            headers ??
            (token != null
                ? headersWithAuthContent(token)
                : headersWithContent);
      }
      // Dio must generate the multipart boundary itself. Keeping the global
      // application/json header here makes uploaded files arrive as an
      // invalid JSON request on stricter servers.
      if (body is FormData) {
        finalHeaders = Map<String, String>.from(finalHeaders)
          ..removeWhere((key, _) => key.toLowerCase() == 'content-type');
      }
      final language = CacheHelper.getData(key: 'LOCALE')?.toString() ?? 'en';
      finalHeaders = {
        ...finalHeaders,
        'Accept-Language': language,
        'Content-Language': language,
      };

      final response = await _dio.request(
        cleanPath,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: finalHeaders,
          responseType: responseType,
        ),
      );

      debugPrint('--- ✅ Success Response: ${response.statusCode} ---');
      return response;
    } on DioException catch (e) {
      debugPrint('--- ❌ Server Error ---');
      if (e.response != null) {
        debugPrint('Status: ${e.response?.statusCode}');
        debugPrint('Data: ${e.response?.data}');
      }
      if (preserveDioError) rethrow;
      throw DioErrorHandler.handle(e);
    } catch (e) {
      debugPrint('--- ⚠️ System Error: $e ---');
      final ar = CacheHelper.getData(key: 'LOCALE') == 'ar';
      throw Exception(
        ar ? 'حدث خطأ غير متوقع.' : 'An unexpected error occurred.',
      );
    }
  }

  static Future<Response> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    bool preserveDioError = false,
  }) async {
    return _makeRequest(
      'POST',
      url,
      body: body,
      headers: headers,
      preserveDioError: preserveDioError,
    );
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

  static Future<Response> getBytes(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _makeRequest(
      'GET',
      url,
      headers: headers,
      queryParameters: queryParameters,
      responseType: ResponseType.bytes,
    );
  }

  static Future<Response> put(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _makeRequest('PUT', url, body: body, headers: headers);
  }

  static Future<Response> patch(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _makeRequest('PATCH', url, body: body, headers: headers);
  }

  static Future<Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _makeRequest('DELETE', url, headers: headers);
  }
}
