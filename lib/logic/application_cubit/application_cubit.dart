import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/application_repo.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationStates> {
  final ApplicationRepo applicationRepo;
  ApplicationCubit(this.applicationRepo) : super(ApplicationInitialState());

  static ApplicationCubit get(context) => BlocProvider.of(context);

  void getMyApplications() {
    emit(ApplicationLoadingState());
    applicationRepo.getMyApplications().then((list) {
      emit(GetApplicationsSuccessState(list));
    }).catchError((error) {
      emit(ApplicationErrorState(error.toString()));
    });
  }

  void applyForJob(int jobId, Map<String, dynamic> data) {
    emit(ApplicationLoadingState());
    applicationRepo.applyForJob(jobId, data).then((app) {
      if (app.id != -1) {
        emit(ApplicationActionSuccessState(app.message ?? 'Applied Successfully'));
      } else {
        emit(ApplicationErrorState(app.message ?? 'Error'));
      }
    });
  }

  void getApplicationDetails(int id) {
    emit(ApplicationLoadingState());
    applicationRepo.getApplicationDetails(id).then((app) {
      if (app.id != -1) {
        emit(GetApplicationDetailsSuccessState(app));
      } else {
        emit(ApplicationErrorState(app.message ?? 'Error'));
      }
    });
  }
}
