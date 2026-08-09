import 'package:work_key/data/api/jobs_api.dart';
import 'package:work_key/data/models/job_filter_schema.dart';
import 'package:work_key/data/models/job_model.dart';

class ExploreJobsPage {
  final List<JobModel> jobs;
  final int currentPage;
  final bool hasMore;
  const ExploreJobsPage({required this.jobs, required this.currentPage, required this.hasMore});
}

class ExploreJobsRepo {
  final JobsApi _api;
  ExploreJobsRepo({JobsApi? api}) : _api = api ?? JobsApi();

  Future<JobFilterSchema> getFilterSchema(String language) async {
    final response = await _api.getFilterSchema(language: language);
    return JobFilterSchema.fromMap(Map<String, dynamic>.from(response.data));
  }

  Future<ExploreJobsPage> getJobs(Map<String, dynamic> query) async {
    final response = await _api.getJobs(query: query);
    final root = Map<String, dynamic>.from(response.data);
    final raw = root['data'];
    final payload = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final meta = payload['meta'] is Map ? Map<String, dynamic>.from(payload['meta']) : payload;
    final list = raw is List ? raw : payload['data'] is List ? payload['data'] : const [];
    final current = int.tryParse('${meta['current_page'] ?? query['page'] ?? 1}') ?? 1;
    final last = int.tryParse('${meta['last_page'] ?? current}') ?? current;
    return ExploreJobsPage(
      jobs: (list as List).whereType<Map>().map((item) => JobModel.fromMap(Map<String, dynamic>.from(item))).toList(),
      currentPage: current,
      hasMore: (payload['links'] is Map && payload['links']['next'] != null) || current < last,
    );
  }

  Future<List<JobModel>> getRecommended() async {
    final response = await _api.getRecommendedJobs(limit: 20);
    final raw = response.data['data'];
    final list = raw is List ? raw : raw is Map && raw['data'] is List ? raw['data'] : const [];
    return (list as List).whereType<Map>().map((item) => JobModel.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  Future<List<JobFilterOption>> getRemoteOptions(JobFilterOptionsSource source, String search, String language) async {
    final response = await _api.getRemoteOptions(source.endpoint, searchParameter: source.searchParameter, search: search, language: language);
    final raw = response.data['data'];
    final list = raw is List ? raw : raw is Map && raw['data'] is List ? raw['data'] : const [];
    return (list as List).whereType<Map>().map((item) {
      return JobFilterOption(key: item[source.valueField], value: '${item[source.labelField] ?? ''}');
    }).toList();
  }
}
