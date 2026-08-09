import '../../data/models/profile_model.dart';
import '../../data/models/experience_model.dart';
import '../../data/models/education_model.dart';

abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates {}

class ProfileLoadingState extends ProfileStates {}

class GetProfileSuccessState extends ProfileStates {
  final ProfileModel profileModel;
  GetProfileSuccessState(this.profileModel);
}

class UpdateProfileSuccessState extends ProfileStates {
  final ProfileModel profileModel;
  UpdateProfileSuccessState(this.profileModel);
}

class GetExperiencesSuccessState extends ProfileStates {
  final List<ExperienceModel> experiences;
  GetExperiencesSuccessState(this.experiences);
}

class GetEducationSuccessState extends ProfileStates {
  final List<EducationModel> education;
  GetEducationSuccessState(this.education);
}

class ProfileErrorState extends ProfileStates {
  final String error;
  ProfileErrorState(this.error);
}
