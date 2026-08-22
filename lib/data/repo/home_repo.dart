import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/home_api.dart';
import '../models/home_response_model.dart';
import '../../services/applied_jobs_store.dart';
import '../../utils/shared preferences.dart';

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
      await AppliedJobsStore.refresh();
      final response = await _homeApi.getHome();
      if (response.data['success'] == true) {
        final home = HomeResponseModel.fromMap(response.data);
        for (final job in [...home.recommendedJobs, ...home.latestJobs]) {
          if (AppliedJobsStore.contains(job.id)) job.hasApplied = true;
        }
        if (kDebugMode) {
          for (final company in home.featuredCompanies) {
            debugPrint(
              '[Company] name=${company.name} | website=not_provided_by_home | logo_url=${company.logoUrl ?? 'null'} | cover_url=${company.coverUrl ?? 'null'}',
            );
          }
        }
        return home;
      }
      throw HomeRequestException(
        0,
        response.data['message']?.toString() ?? 'Unable to load home data',
      );
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
    final ar = CacheHelper.getData(key: 'LOCALE') == 'ar';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ar
            ? 'انتهت مهلة الاتصال. تحقق من الشبكة وحاول مجددًا.'
            : 'The connection timed out. Check your network and try again.';
      case DioExceptionType.connectionError:
        return ar
            ? 'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.'
            : 'Could not connect to the internet. Check your network and try again.';
      default:
        return ar
            ? 'تعذر تحميل الصفحة الرئيسية.'
            : 'Unable to load the home page.';
    }
  }
}
