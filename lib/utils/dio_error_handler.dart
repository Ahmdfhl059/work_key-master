import 'package:dio/dio.dart';

class DioErrorHandler {
  static Exception handle(DioException dioException) {
    String message = 'حدث خطأ غير متوقع';

    if (dioException.response != null) {
      final data = dioException.response?.data;

      if (data is Map && data['message'] != null) {
        message = data['message'];
      } else {
        message = 'خطأ من السيرفر (${dioException.response?.statusCode})';
      }
    } else if (dioException.type == DioExceptionType.connectionTimeout) {
      message = 'انتهت مهلة الاتصال';
    } else if (dioException.type == DioExceptionType.connectionError) {
      message = 'لا يوجد اتصال بالإنترنت';
    }

    return Exception(message);
  }
}
