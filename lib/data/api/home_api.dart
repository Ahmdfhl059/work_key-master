import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class HomeApi {
  Future<Response> getHome() async {
    // Home needs the original status and error code to handle 401/403 correctly.
    return await RemoteApi.get('home', preserveDioError: true);
  }
}
