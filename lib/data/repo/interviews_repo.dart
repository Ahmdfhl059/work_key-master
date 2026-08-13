import '../api/interviews_api.dart';
import '../models/interview_model.dart';

class InterviewsRepo {
  final InterviewsApi _interviewsApi;

  InterviewsRepo({InterviewsApi? interviewsApi})
    : _interviewsApi = interviewsApi ?? InterviewsApi();

  Future<InterviewListResponse> getMyInterviews({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _interviewsApi.getMyInterviews(
      page: page,
      perPage: perPage,
    );
    return InterviewListResponse.fromMap(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<InterviewModel> getInterviewDetails(int id) async {
    final response = await _interviewsApi.getInterviewDetails(id);
    final root = Map<String, dynamic>.from(response.data as Map);
    final data = root['data'];
    if (data is! Map) throw const FormatException('Interview data is missing.');
    return InterviewModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<InterviewModel> confirmInterview(int id) async {
    final response = await _interviewsApi.confirmInterview(id);
    final root = Map<String, dynamic>.from(response.data as Map);
    final data = root['data'];
    if (data is! Map) throw const FormatException('Interview data is missing.');
    return InterviewModel.fromMap(Map<String, dynamic>.from(data));
  }
}
