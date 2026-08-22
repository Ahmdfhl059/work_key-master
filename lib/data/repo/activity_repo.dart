import 'package:work_key/data/api/activity_api.dart';
import 'package:work_key/data/models/activity_response_model.dart';

class ActivityRepo {
  final ActivityApi _api = ActivityApi();
  Future<ActivityResponse> getActivity(Map<String, dynamic> query) async =>
      ActivityResponse.fromMap(
        Map<String, dynamic>.from((await _api.getActivity(query)).data),
      );
  Future<void> markRead(int id) async {
    await _api.markRead(id);
  }

  Future<void> markAllRead() async {
    await _api.markAllRead();
  }
}
