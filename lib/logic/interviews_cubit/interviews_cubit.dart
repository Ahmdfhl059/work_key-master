import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/interviews_repo.dart';
import 'interviews_state.dart';

class InterviewsCubit extends Cubit<InterviewsStates> {
  final InterviewsRepo interviewsRepo;
  InterviewsCubit(this.interviewsRepo) : super(InterviewsInitialState());

  static InterviewsCubit get(context) => BlocProvider.of(context);

  void getMyInterviews() {
    emit(InterviewsLoadingState());
    interviewsRepo.getMyInterviews().then((list) {
      emit(GetInterviewsSuccessState(list));
    }).catchError((error) {
      emit(InterviewsErrorState(error.toString()));
    });
  }

  void getInterviewDetails(int id) {
    emit(InterviewsLoadingState());
    interviewsRepo.getInterviewDetails(id).then((interview) {
      if (interview.id != -1) {
        emit(GetInterviewDetailsSuccessState(interview));
      } else {
        emit(InterviewsErrorState(interview.message ?? 'Failed to load interview details'));
      }
    }).catchError((error) {
      emit(InterviewsErrorState(error.toString()));
    });
  }
}
