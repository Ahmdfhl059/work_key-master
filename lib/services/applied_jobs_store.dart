import '../data/api/application_api.dart';
import '../utils/shared preferences.dart';

/// Keeps application state consistent when a public jobs response omits
/// `viewer_application`. The backend applications list remains the source of
/// truth and successful submissions are reflected immediately.
class AppliedJobsStore {
  AppliedJobsStore._();

  static final Set<int> _jobIds = <int>{};
  static DateTime? _loadedAt;
  static String? _token;

  static bool contains(int jobId) => _jobIds.contains(jobId);

  static void markApplied(int jobId) {
    if (jobId >= 0) _jobIds.add(jobId);
  }

  static Future<void> refresh({bool force = false}) async {
    final token = CacheHelper.getData(key: 'token')?.toString();
    if (token == null || token.isEmpty) {
      _jobIds.clear();
      _token = null;
      _loadedAt = null;
      return;
    }
    if (_token != token) {
      _jobIds.clear();
      _token = token;
      _loadedAt = null;
    }
    if (!force &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < const Duration(minutes: 2)) {
      return;
    }
    try {
      final response = await ApplicationApi().getMyApplications(
        query: {'group': 'all', 'per_page': 100},
      );
      final root = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};
      final data = root['data'];
      final list = data is List
          ? data
          : data is Map && data['data'] is List
          ? data['data'] as List
          : const [];
      final ids = <int>{};
      for (final item in list.whereType<Map>()) {
        final job = item['job_posting'] is Map
            ? item['job_posting'] as Map
            : item['job'] is Map
            ? item['job'] as Map
            : const {};
        final id = int.tryParse('${job['id'] ?? item['job_id'] ?? ''}');
        if (id != null && id >= 0) ids.add(id);
      }
      _jobIds
        ..clear()
        ..addAll(ids);
      _loadedAt = DateTime.now();
    } catch (_) {
      // Preserve the last known set during transient network failures.
    }
  }
}
