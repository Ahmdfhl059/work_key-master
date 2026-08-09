import '../../data/models/job_model.dart';

abstract class JobStates {}

class JobInitialState extends JobStates {}

class JobLoadingState extends JobStates {}

class GetJobsSuccessState extends JobStates {
  final List<JobModel> jobs;
  GetJobsSuccessState(this.jobs);
}

class GetJobDetailsSuccessState extends JobStates {
  final JobModel jobModel;
  GetJobDetailsSuccessState(this.jobModel);
}

class JobErrorState extends JobStates {
  final String error;
  JobErrorState(this.error);
}
