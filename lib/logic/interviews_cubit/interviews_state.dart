import '../../data/models/interview_model.dart';

abstract class InterviewsStates {}

class InterviewsInitialState extends InterviewsStates {}

class InterviewsLoadingState extends InterviewsStates {}

class GetInterviewsSuccessState extends InterviewsStates {
  final List<InterviewModel> interviews;
  GetInterviewsSuccessState(this.interviews);
}

class GetInterviewDetailsSuccessState extends InterviewsStates {
  final InterviewModel interviewModel;
  GetInterviewDetailsSuccessState(this.interviewModel);
}

class InterviewsErrorState extends InterviewsStates {
  final String error;
  InterviewsErrorState(this.error);
}
