import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/api/profile_api.dart';
import 'package:work_key/data/repo/profile_repo.dart';

class _ProfileApiFake extends ProfileApi {
  int getCalls = 0;

  @override
  Future<Response> getProfile() async {
    getCalls++;
    throw StateError('A second GET must not be required after update');
  }

  @override
  Future<Response> updateProfile(Map<String, dynamic> data) async => Response(
    requestOptions: RequestOptions(path: 'profile'),
    statusCode: 200,
    data: {
      'success': true,
      'message': 'Updated',
      'data': {
        'id': 30,
        'headline': data['headline'],
        'summary': 'Summary',
        'phone': '+963900000000',
        'location': 'Damascus',
        'city': {'id': data['city_id'], 'name': 'Damascus'},
        'availability_status': 'available_now',
        'available_from': null,
        'user': {'id': 45, 'name': 'Ahmad', 'email': 'a@example.com'},
        'experiences': [],
        'education': [],
        'skills': [],
      },
    },
  );
}

void main() {
  test(
    'profile update uses the canonical PUT response without a second GET',
    () async {
      final api = _ProfileApiFake();
      final profile = await ProfileRepo(
        profileApi: api,
      ).updateProfile({'headline': 'Flutter Developer', 'city_id': 11});

      expect(profile.id, 30);
      expect(profile.headline, 'Flutter Developer');
      expect(profile.availabilityStatus, 'available_now');
      expect(profile.cityId, 11);
      expect(profile.cityName, 'Damascus');
      expect(api.getCalls, 0);
    },
  );
}
