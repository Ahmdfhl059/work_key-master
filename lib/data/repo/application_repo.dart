import 'package:dio/dio.dart';
import '../api/application_api.dart';
import '../models/application_model.dart';
import '../models/applications_response_model.dart';
import '../../services/applied_jobs_store.dart';

class ApplicationRepo {
  final ApplicationApi _applicationApi = ApplicationApi();

  Future<ApplicationListResponse> getMyApplicationsPage(
    Map<String, dynamic> query,
  ) async {
    final response = await _applicationApi.getMyApplications(query: query);
    return ApplicationListResponse.fromMap(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<JobApplication> getTypedApplicationDetails(int id) async {
    final response = await _applicationApi.getApplicationDetails(id);
    final data = response.data['data'];
    return JobApplication.fromMap(
      data is Map ? Map<String, dynamic>.from(data) : const {},
    );
  }

  Future<void> withdrawTypedApplication(int id, {String? reason}) async {
    await _applicationApi.withdrawApplication(id, reason: reason);
  }

  Future<Map<String, dynamic>> getInformationRequest(int id) async {
    final response = await _applicationApi.getInformationRequest(id);
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] != true) {
      throw StateError(root['message']?.toString() ?? 'Request not found');
    }
    return root['data'] is Map
        ? Map<String, dynamic>.from(root['data'])
        : <String, dynamic>{};
  }

  Future<String> respondToInformationRequest(int id, FormData data) async {
    final response = await _applicationApi.respondToInformationRequest(
      id,
      data,
    );
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] != true) {
      throw StateError(root['message']?.toString() ?? 'Response failed');
    }
    return root['message']?.toString() ?? 'Information submitted';
  }

  Future<ApplicationModel> applyForJob(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    print('--- 📝 ApplicationRepo: Applying to Job ID: $jobId ---');
    print('Payload: $data');
    try {
      Response response = await _applicationApi.applyToJob(jobId, data);
      print('--- 📝 ApplicationRepo: Received Response ---');
      print('Status: ${response.statusCode}, Data: ${response.data}');

      Map<String, dynamic> responseData = Map<String, dynamic>.from(
        response.data as Map,
      );
      if (responseData['success'] == true ||
          response.statusCode == 200 ||
          response.statusCode == 201) {
        AppliedJobsStore.markApplied(jobId);
        final raw = responseData['data'];
        final applicationData = raw is Map && raw['application'] is Map
            ? raw['application']
            : raw is Map && raw['job_application'] is Map
            ? raw['job_application']
            : raw;
        ApplicationModel application = ApplicationModel.fromMap(
          applicationData is Map
              ? Map<String, dynamic>.from(applicationData)
              : const {},
        );
        application.message = responseData['message'];
        return application;
      } else {
        ApplicationModel errorApp = ApplicationModel.initial();
        errorApp.message = responseData['message'];
        return errorApp;
      }
    } catch (e) {
      print('--- 📝 ApplicationRepo ERROR: $e ---');
      ApplicationModel errorApp = ApplicationModel.initial();
      errorApp.message = e.toString();
      return errorApp;
    }
  }

  Future<List<ApplicationModel>> getMyApplications() async {
    print('--- 📝 ApplicationRepo: Fetching My Applications ---');
    try {
      Response response = await _applicationApi.getMyApplications();
      Map<String, dynamic> responseData = response.data;
      if (responseData['success'] == true) {
        // فحص هيكلية البيانات (Paginated or List)
        dynamic rawData = responseData['data'];
        List<dynamic> list = (rawData is List)
            ? rawData
            : (rawData['data'] ?? []);
        print('Applications Found: ${list.length}');
        return list.map((e) => ApplicationModel.fromMap(e)).toList();
      }
      return [];
    } catch (e) {
      print('--- 📝 ApplicationRepo ERROR: $e ---');
      return [];
    }
  }

  Future<ApplicationModel> getApplicationDetails(int id) async {
    try {
      Response response = await _applicationApi.getApplicationDetails(id);
      if (response.data['success'] == true) {
        return ApplicationModel.fromMap(response.data['data']);
      }
      return ApplicationModel.initial();
    } catch (e) {
      return ApplicationModel.initial();
    }
  }

  Future<String> withdrawApplication(int id) async {
    print('--- 📝 ApplicationRepo: Withdrawing Application ID: $id ---');
    try {
      Response response = await _applicationApi.withdrawApplication(id);
      return response.data['message'] ?? 'Application withdrawn';
    } catch (e) {
      return e.toString();
    }
  }
}
