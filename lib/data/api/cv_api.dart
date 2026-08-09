import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class CvApi {
  Future<Response> getCvFiles() async {
    return await RemoteApi.get('cv');
  }

  Future<Response> uploadCv(FormData formData) async {
    return await RemoteApi.post('cv/upload', body: formData);
  }

  Future<Response> getCvFileDetails(int id) async {
    return await RemoteApi.get('cv/$id');
  }

  Future<Response> getParsedCv(int id) async {
    return await RemoteApi.get('cv/$id/parsed');
  }

  // تحديث المسودة يدوياً (تعديل بيانات الـ AI)
  Future<Response> updateCvDraft(int id, Map<String, dynamic> data) async {
    return await RemoteApi.put('cv/$id/review', body: data);
  }

  Future<Response> confirmCvReview(int id) async {
    return await RemoteApi.post('cv/$id/confirm');
  }

  Future<Response> makeCvPrimary(int id) async {
    return await RemoteApi.post('cv/$id/make-primary');
  }

  Future<Response> deleteCv(int id) async {
    return await RemoteApi.delete('cv/$id');
  }

  // --- Profile Suggestions ---
  Future<Response> getCvSuggestions(int cvFileId) async {
    return await RemoteApi.get('cv/$cvFileId/suggestions');
  }

  Future<Response> generateCvSuggestions(int cvFileId) async {
    return await RemoteApi.post('cv/$cvFileId/suggestions/generate');
  }

  Future<Response> acceptSuggestion(int suggestionId, Map<String, dynamic>? editedValue) async {
    return await RemoteApi.post('profile/suggestions/$suggestionId/accept', body: {
      'edited_value': editedValue,
    });
  }

  Future<Response> rejectSuggestion(int suggestionId, String reason) async {
    return await RemoteApi.post('profile/suggestions/$suggestionId/reject', body: {
      'reason': reason,
    });
  }

  Future<Response> applyBulkSuggestions(List<int> ids) async {
    return await RemoteApi.post('profile/suggestions/apply-bulk', body: {
      'suggestion_ids': ids,
    });
  }
}
