import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class ApplicationApi {
  // --- Job Seeker Applications ---
  
  // التقديم على وظيفة مع إرسال الـ CV والـ Cover Letter والموافقة
  Future<Response> applyToJob(int jobId, Map<String, dynamic> data) async {
    return await RemoteApi.post('/jobs/$jobId/applications', body: data);
  }

  Future<Response> getMyApplications({Map<String, dynamic>? query}) async {
    return await RemoteApi.get('/applications/my', queryParameters: query);
  }

  Future<Response> getApplicationDetails(int id) async {
    return await RemoteApi.get('/applications/$id');
  }

  Future<Response> withdrawApplication(int id, {String? reason}) async {
    return await RemoteApi.post('/applications/$id/withdraw', body: {if (reason?.trim().isNotEmpty == true) 'reason': reason!.trim()});
  }

  // --- Employer Applications ---
  
  Future<Response> getJobApplications(int jobId) async {
    return await RemoteApi.get('/jobs/$jobId/applications');
  }

  Future<Response> updateApplicationStatus(int id, String status, {String? note}) async {
    return await RemoteApi.post('/applications/$id/status', body: {
      'status': status,
      'note': note,
    });
  }
}
