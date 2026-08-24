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

  Future<Response> downloadCv(int id) async {
    return await RemoteApi.getBytes('cv/$id/download');
  }

  Future<Response> getParsedCv(int id) async {
    return await RemoteApi.get('cv/$id/parsed');
  }

  Future<Response> getCvReview(int id) async {
    return await RemoteApi.get('cv/$id/review');
  }

  Future<Response> confirmCvReview(int id) async {
    return await RemoteApi.post('cv/$id/confirm');
  }

  Future<Response> cancelCv(int id) async {
    return await RemoteApi.post('cv/$id/cancel');
  }

  // --- Profile Suggestions ---
  Future<Response> getCvSuggestions(int cvFileId) async {
    return await RemoteApi.get('cv/$cvFileId/suggestions');
  }

  Future<Response> generateCvSuggestions(int cvFileId) async {
    return await RemoteApi.post('cv/$cvFileId/suggestions/generate');
  }

  Future<Response> decideBulkSuggestions(
    int cvFileId,
    List<int> suggestionIds,
    String decision,
  ) async {
    return await RemoteApi.post(
      'cv/$cvFileId/suggestions/decisions',
      body: {'suggestion_ids': suggestionIds, 'decision': decision},
    );
  }

  Future<Response> acceptSuggestion(
    int suggestionId,
    Map<String, dynamic>? editedValue,
  ) async {
    return await RemoteApi.post(
      'profile/suggestions/$suggestionId/accept',
      body: buildAcceptSuggestionBody(editedValue),
    );
  }

  Future<Response> rejectSuggestion(int suggestionId, String reason) async {
    return await RemoteApi.post(
      'profile/suggestions/$suggestionId/reject',
      body: {'reason': reason},
    );
  }
}

/// Builds the accept payload expected by `AcceptProfileSuggestionRequest`.
///
/// Omitting `edited_value` means "use the CV proposal unchanged". Sending an
/// empty object instead marks the suggestion as a user edit and makes the
/// backend replace structured values (such as an experience) with empty data.
Map<String, dynamic> buildAcceptSuggestionBody(
  Map<String, dynamic>? editedValue,
) => editedValue == null || editedValue.isEmpty
    ? <String, dynamic>{}
    : <String, dynamic>{'edited_value': editedValue};
