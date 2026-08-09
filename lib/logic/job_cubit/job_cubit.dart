import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/jobs_repo.dart';
import 'job_state.dart';

class JobCubit extends Cubit<JobStates> {
  final JobsRepo jobsRepo;
  JobCubit(this.jobsRepo) : super(JobInitialState());

  static JobCubit get(context) => BlocProvider.of(context);

  void getJobs({Map<String, dynamic>? query}) {
    emit(JobLoadingState());
    jobsRepo.getJobs(query: query).then((jobs) {
      emit(GetJobsSuccessState(jobs));
    }).catchError((error) {
      emit(JobErrorState(error.toString()));
    });
  }

  void getMyJobs() {
    emit(JobLoadingState());
    jobsRepo.getMyJobs().then((jobs) {
      emit(GetJobsSuccessState(jobs));
    }).catchError((error) {
      emit(JobErrorState(error.toString()));
    });
  }

  void getJobDetails(int id) {
    emit(JobLoadingState());
    jobsRepo.getJobDetails(id).then((job) {
      if (job.id != -1) {
        emit(GetJobDetailsSuccessState(job));
      } else {
        emit(JobErrorState(job.message ?? 'Failed to get job details'));
      }
    }).catchError((error) {
      emit(JobErrorState(error.toString()));
    });
  }

  void getRecommendedJobs() {
    emit(JobLoadingState());
    jobsRepo.getRecommendedJobs().then((jobs) {
      emit(GetJobsSuccessState(jobs));
    }).catchError((error) {
      emit(JobErrorState(error.toString()));
    });
  }
}
