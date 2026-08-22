import '../api/reference_api.dart';
import '../models/city_model.dart';

class ReferenceRepo {
  final ReferenceApi _api;

  ReferenceRepo({ReferenceApi? api}) : _api = api ?? ReferenceApi();

  Future<List<CityModel>> getCities() async {
    final response = await _api.getCities();
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    final raw = root['data'];
    final list = raw is List
        ? raw
        : raw is Map && raw['data'] is List
        ? raw['data'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((item) => CityModel.fromMap(Map<String, dynamic>.from(item)))
        .where((city) => city.id >= 0 && city.name.isNotEmpty)
        .toList();
  }
}
