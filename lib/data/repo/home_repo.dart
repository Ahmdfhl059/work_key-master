import 'package:dio/dio.dart';
import '../api/home_api.dart';
import '../models/home_response_model.dart';

class HomeRequestException implements Exception {
  final int? statusCode;
  final String? errorCode;
  final String message;

  HomeRequestException(this.statusCode, this.message, {this.errorCode});

  @override
  String toString() => message;
}

class HomeRepo {
  final HomeApi _homeApi = HomeApi();

  Future<HomeResponseModel> getHome() async {
    try {
      final response = await _homeApi.getHome();
      if (response.data['success'] == true) {
        return HomeResponseModel.fromMap(response.data);
      }
      throw HomeRequestException(0, response.data['message']?.toString() ?? 'Unable to load home data');
    } on HomeRequestException {
      rethrow;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final responseMessage = data is Map ? data['message']?.toString() : null;
      final errorCode = data is Map
          ? (data['code'] ?? data['error_code'] ?? data['error'])?.toString()
          : null;
      throw HomeRequestException(
        statusCode,
        responseMessage ?? _networkMessage(e),
        errorCode: errorCode,
      );
    } catch (e) {
      throw HomeRequestException(null, e.toString());
    }
  }

  String _networkMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال. تحقق من الشبكة وحاول مجددًا.';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.';
      default:
        return 'تعذر تحميل الصفحة الرئيسية.';
    }
  }
}
