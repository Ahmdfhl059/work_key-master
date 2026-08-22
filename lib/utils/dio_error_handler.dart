import 'package:dio/dio.dart';
import 'shared preferences.dart';

class DioErrorHandler {
  static Exception handle(DioException dioException) {
    final ar = CacheHelper.getData(key: 'LOCALE') == 'ar';
    String message = ar
        ? 'حدث خطأ غير متوقع.'
        : 'An unexpected error occurred.';

    if (dioException.response != null) {
      final data = dioException.response?.data;

      if (data is Map && data['message'] != null) {
        final serverMessage = data['message'].toString();
        final languageMismatch = ar
            ? !_containsArabic(serverMessage)
            : _containsArabic(serverMessage);
        message = languageMismatch
            ? (ar
                  ? 'تعذر إكمال الطلب. يرجى المحاولة مجدداً.'
                  : 'The request could not be completed. Please try again.')
            : serverMessage;
      } else {
        message = ar
            ? 'خطأ من الخادم (${dioException.response?.statusCode}).'
            : 'Server error (${dioException.response?.statusCode}).';
      }
    } else if (dioException.type == DioExceptionType.connectionTimeout) {
      message = ar
          ? 'انتهت مهلة الاتصال. حاول مجدداً.'
          : 'The connection timed out. Please try again.';
    } else if (dioException.type == DioExceptionType.connectionError) {
      message = ar
          ? 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.'
          : 'Could not connect to the server. Check your internet connection.';
    }

    return Exception(message);
  }

  static bool _containsArabic(String value) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}
