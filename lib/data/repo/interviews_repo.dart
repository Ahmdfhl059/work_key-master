import 'package:dio/dio.dart';
import '../api/interviews_api.dart';
import '../models/interview_model.dart';

class InterviewsRepo {
  final InterviewsApi _interviewsApi = InterviewsApi();

  Future<List<InterviewModel>> getMyInterviews() async {
    try {
      Response response = await _interviewsApi.getMyInterviews();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => InterviewModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<InterviewModel> getInterviewDetails(int id) async {
    try {
      Response response = await _interviewsApi.getInterviewDetails(id);
      if (response.data['success'] == true) {
        InterviewModel model = InterviewModel.fromMap(response.data['data']);
        model.message = response.data['message'];
        return model;
      } else {
        InterviewModel error = InterviewModel.initial();
        error.message = response.data['message'];
        return error;
      }
    } catch (e) {
      InterviewModel error = InterviewModel.initial();
      error.message = e.toString();
      return error;
    }
  }
}
