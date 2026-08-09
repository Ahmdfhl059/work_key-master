import 'package:dio/dio.dart';
import '../api/jobs_api.dart';
import '../models/job_model.dart';

class JobsRepo {
  final JobsApi _jobsApi = JobsApi();

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
        return jobsList.map((e) => JobModel.fromMap(e)).toList();
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
      Response response = await _jobsApi.getJobDetails(id);
      Map<String, dynamic> responseData = response.data;
      if (responseData['success'] == true) {
        JobModel job = JobModel.fromMap(responseData['data']);
        job.message = responseData['message'];
        return job;
      } else {
        JobModel error = JobModel.initial();
        error.message = responseData['message'];
        return error;
      }
    } catch (e) {
      JobModel error = JobModel.initial();
      error.message = e.toString();
      return error;
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
}
