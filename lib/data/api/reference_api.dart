import 'package:dio/dio.dart';

import '../../utils/dio_methods.dart';

class ReferenceApi {
  Future<Response> getCities() => RemoteApi.get(
    'reference/cities',
    queryParameters: const {'active_only': true},
  );
}
