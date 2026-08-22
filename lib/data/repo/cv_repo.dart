import 'package:dio/dio.dart';

import '../api/cv_api.dart';
import '../models/cv_file_model.dart';

class CvRepo {
  final CvApi _cvApi;

  CvRepo({CvApi? cvApi}) : _cvApi = cvApi ?? CvApi();

  Future<List<CvFileModel>> getCvFiles() async {
    final response = await _cvApi.getCvFiles();
    final root = _map(response.data);
    if (root['success'] != true) throw StateError(_message(root));
    final data = root['data'];
    final list = data is List
        ? data
        : data is Map && data['data'] is List
        ? data['data'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((item) => CvFileModel.fromMap(Map<String, dynamic>.from(item)))
        // The API keeps immutable audit records after a CV is cancelled,
        // archived, expired, or its file is purged. Those records are not
        // usable documents and must not appear as uploaded CVs in the profile.
        .where(
          (item) =>
              item.id >= 0 &&
              !item.isCancelled &&
              !item.isArchived &&
              !item.isExpired &&
              item.fileAvailable,
        )
        .toList();
  }

  Future<CvFileModel> uploadCv(FormData formData) async {
    final response = await _cvApi.uploadCv(formData);
    final root = _map(response.data);
    final data = _map(root['data']);
    if (root['success'] != true || data.isEmpty) {
      throw StateError(_message(root));
    }
    return CvFileModel.fromMap(data);
  }

  Future<Map<String, dynamic>> getParsedCv(int id) async {
    final response = await _cvApi.getParsedCv(id);
    return _requiredData(response);
  }

  Future<Map<String, dynamic>> getCvReview(int id) async {
    final response = await _cvApi.getCvReview(id);
    return _requiredData(response);
  }

  Future<Map<String, dynamic>> confirmCvReview(int id) async {
    final response = await _cvApi.confirmCvReview(id);
    return _requiredData(response);
  }

  Future<Map<String, dynamic>> cancelCv(int id) async {
    final response = await _cvApi.cancelCv(id);
    return _requiredData(response);
  }

  Future<String> generateSuggestions(int id) async {
    final response = await _cvApi.generateCvSuggestions(id);
    final root = _map(response.data);
    if (root['success'] != true) throw StateError(_message(root));
    return _message(root, 'Suggestions generated');
  }

  Future<List<dynamic>> getCvSuggestions(int id) async {
    final response = await _cvApi.getCvSuggestions(id);
    final root = _map(response.data);
    if (root['success'] != true) throw StateError(_message(root));
    final data = root['data'];
    return data is List ? data : const [];
  }

  Future<Map<String, dynamic>> acceptSuggestion(
    int id,
    Map<String, dynamic>? editedValue,
  ) async {
    final response = await _cvApi.acceptSuggestion(id, editedValue);
    return _requiredData(response);
  }

  Future<Map<String, dynamic>> rejectSuggestion(int id, String reason) async {
    final response = await _cvApi.rejectSuggestion(id, reason);
    return _requiredData(response);
  }

  Future<Map<String, dynamic>> decideBulkSuggestions(
    int cvFileId,
    List<int> ids,
    String decision,
  ) async {
    final response = await _cvApi.decideBulkSuggestions(
      cvFileId,
      ids,
      decision,
    );
    return _requiredData(response);
  }

  Map<String, dynamic> _requiredData(Response response) {
    final root = _map(response.data);
    if (root['success'] != true) throw StateError(_message(root));
    final data = _map(root['data']);
    if (data.isEmpty) throw const FormatException('CV response is missing.');
    return data;
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String _message(
  Map<String, dynamic> root, [
  String fallback = 'CV action failed',
]) {
  final message = root['message']?.toString().trim() ?? '';
  return message.isEmpty ? fallback : message;
}
