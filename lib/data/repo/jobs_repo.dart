import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/jobs_api.dart';
import '../models/job_model.dart';
import '../../services/applied_jobs_store.dart';

class JobsRepo {
  final JobsApi _jobsApi;

  JobsRepo({JobsApi? jobsApi}) : _jobsApi = jobsApi ?? JobsApi();

  Future<List<JobModel>> getJobs({Map<String, dynamic>? query}) async {
    print('--- 📂 JobsRepo: Fetching Jobs ---');
    try {
      Response response = await _jobsApi.getJobs(query: query);
      Map<String, dynamic> responseData = response.data;

      print('--- 📂 JobsRepo: Raw Data Received ---');

      if (responseData['success'] == true) {
        dynamic data = responseData['data'];
        List<dynamic> jobsList = [];

        // منطق ذكي للتعامل مع هيكلية البيانات (Pagination vs Direct List)
        if (data is List) {
          jobsList = data;
          print('Structure: Direct List');
        } else if (data is Map && data['data'] is List) {
          jobsList = data['data'];
          print('Structure: Paginated Object');
        }

        print('Jobs Count: ${jobsList.length}');
        final jobs = jobsList.map((e) => JobModel.fromMap(e)).toList();
        _logCompanyMedia(jobs);
        return jobs;
      }
      print('JobsRepo: Success is false or data is null');
      return [];
    } catch (e) {
      print('--- 📂 JobsRepo ERROR: $e ---');
      return [];
    }
  }

  Future<JobModel> getJobDetails(int id) async {
    try {
      await AppliedJobsStore.refresh();
      final response = await _jobsApi.getJobDetails(id);
      final responseData = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final data = responseData['data'];
      if (responseData['success'] != true || data is! Map || data.isEmpty) {
        final empty = JobModel.initial();
        empty.message = responseData['message']?.toString();
        return empty;
      }

      final job = JobModel.fromMap(Map<String, dynamic>.from(data));
      if (AppliedJobsStore.contains(job.id)) {
        job.hasApplied = true;
        job.canApply = false;
      }
      _logCompanyMedia([job]);
      job.message = responseData['message']?.toString();
      return job;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return JobModel.initial();
      rethrow;
    }
  }

  Future<List<JobModel>> getRecommendedJobs() async {
    try {
      Response response = await _jobsApi.getRecommendedJobs();
      if (response.data['success'] == true) {
        dynamic data = response.data['data'];
        List<dynamic> list = (data is List) ? data : data['data'] ?? [];
        return list.map((e) => JobModel.fromMap(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<JobModel>> getMyJobs() async {
    try {
      Response response = await _jobsApi.getMyJobs();
      if (response.data['success'] == true) {
        dynamic data = response.data['data'];
        List<dynamic> list = (data is List) ? data : data['data'] ?? [];
        return list.map((e) => JobModel.fromMap(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void _logCompanyMedia(List<JobModel> jobs) {
    if (!kDebugMode) return;
    for (final job in jobs) {
      debugPrint(
        '[Company] name=${job.company.name} | website=${job.company.website.isEmpty ? 'null' : job.company.website} | logo_url=${job.company.logo.isEmpty ? 'null' : job.company.logo}',
      );
    }
  }
}
