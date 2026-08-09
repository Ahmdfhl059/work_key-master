import 'package:dio/dio.dart';
import '../api/cv_api.dart';
import '../models/cv_file_model.dart';

class CvRepo {
  final CvApi _cvApi = CvApi();

  Future<List<CvFileModel>> getCvFiles() async {
    try {
      Response response = await _cvApi.getCvFiles();
      if (response.data['success'] == true) {
        dynamic data = response.data['data'];
        List<dynamic> list = (data is List) ? data : (data['data'] ?? []);
        return list.map((e) => CvFileModel.fromMap(e)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<CvFileModel> uploadCv(FormData formData) async {
    try {
      Response response = await _cvApi.uploadCv(formData);
      if (response.data['success'] == true) {
        return CvFileModel.fromMap(response.data['data']);
      } else {
        CvFileModel error = CvFileModel.initial();
        error.message = response.data['message'];
        return error;
      }
    } catch (e) {
      CvFileModel error = CvFileModel.initial();
      error.message = e.toString();
      return error;
    }
  }

  Future<Map<String, dynamic>> getParsedCv(int id) async {
    try {
      Response response = await _cvApi.getParsedCv(id);
      if (response.data['success'] == true) return response.data['data'];
      return {};
    } catch (e) { return {}; }
  }

  Future<String> updateDraft(int id, Map<String, dynamic> data) async {
    try {
      Response response = await _cvApi.updateCvDraft(id, data);
      return response.data['message'] ?? 'Draft updated';
    } catch (e) { return e.toString(); }
  }

  Future<String> confirmCvReview(int id) async {
    try {
      Response response = await _cvApi.confirmCvReview(id);
      return response.data['message'] ?? 'Confirmed';
    } catch (e) { return e.toString(); }
  }

  Future<String> generateSuggestions(int cvFileId) async {
    try {
      Response response = await _cvApi.generateCvSuggestions(cvFileId);
      return response.data['message'] ?? 'Suggestions generated';
    } catch (e) { return e.toString(); }
  }

  Future<List<dynamic>> getCvSuggestions(int cvFileId) async {
    try {
      Response response = await _cvApi.getCvSuggestions(cvFileId);
      if (response.data['success'] == true) return response.data['data'] ?? [];
      return [];
    } catch (e) { return []; }
  }

  Future<String> acceptSuggestion(int id, Map<String, dynamic>? editedValue) async {
    try {
      Response response = await _cvApi.acceptSuggestion(id, editedValue);
      return response.data['message'] ?? 'Accepted';
    } catch (e) { return e.toString(); }
  }

  Future<String> rejectSuggestion(int id, String reason) async {
    try {
      Response response = await _cvApi.rejectSuggestion(id, reason);
      return response.data['message'] ?? 'Rejected';
    } catch (e) { return e.toString(); }
  }

  Future<String> applyBulkSuggestions(List<int> ids) async {
    try {
      Response response = await _cvApi.applyBulkSuggestions(ids);
      return response.data['message'] ?? 'Synced';
    } catch (e) { return e.toString(); }
  }

  Future<String> makePrimary(int id) async {
    try {
      Response response = await _cvApi.makeCvPrimary(id);
      return response.data['message'] ?? 'Marked as Primary';
    } catch (e) { return e.toString(); }
  }

  Future<String> deleteCv(int id) async {
    try {
      Response response = await _cvApi.deleteCv(id);
      return response.data['message'] ?? 'Deleted';
    } catch (e) { return e.toString(); }
  }
}
