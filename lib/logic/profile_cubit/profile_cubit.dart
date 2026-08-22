import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/profile_repo.dart';
import 'profile_state.dart';
import '../../data/models/skill_model.dart';
import '../../data/models/profile_model.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepo profileRepo;
  ProfileCubit(this.profileRepo) : super(ProfileInitialState());

  static ProfileCubit get(context) => BlocProvider.of(context);

  void getProfile() {
    print('--- 👤 ProfileCubit: Triggering getProfile ---');
    emit(ProfileLoadingState());
    profileRepo
        .getProfile()
        .then((profile) {
          if (profile.id != -1) {
            print('--- 👤 ProfileCubit: Success Emitting ---');
            emit(GetProfileSuccessState(profile));
          } else {
            print('--- 👤 ProfileCubit: Error Emitting ---');
            emit(
              ProfileErrorState(profile.message ?? 'Failed to load profile'),
            );
          }
        })
        .catchError((error) {
          emit(ProfileErrorState(error.toString()));
        });
  }

  Future<ProfileModel?> refreshProfile() async {
    emit(ProfileLoadingState());
    try {
      final profile = await profileRepo.getProfile();
      if (profile.id < 0) {
        emit(ProfileErrorState(profile.message ?? 'Failed to load profile'));
        return null;
      }
      emit(GetProfileSuccessState(profile));
      return profile;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return null;
    }
  }

  /// Publishes the profile returned by the atomic CV confirmation response.
  /// This prevents the profile tab from showing stale data while the follow-up
  /// GET is still in flight.
  void applyConfirmedCvProfile(dynamic payload) {
    if (payload is! Map) return;
    final profile = ProfileModel.fromMap(Map<String, dynamic>.from(payload));
    if (profile.id >= 0) emit(UpdateProfileSuccessState(profile));
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    print('--- 👤 ProfileCubit: Triggering updateProfile ---');
    emit(ProfileLoadingState());
    try {
      final profile = await profileRepo.updateProfile(data);
      if (profile.id != -1) {
        emit(UpdateProfileSuccessState(profile));
        return true;
      }
      emit(ProfileErrorState(profile.message ?? 'Update failed'));
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
    }
    return false;
  }

  Future<void> uploadAvatar(String path) async {
    emit(ProfileLoadingState());
    try {
      final profile = await profileRepo.uploadAvatar(path);
      if (profile.id != -1) {
        emit(UpdateProfileSuccessState(profile));
      } else {
        emit(ProfileErrorState(profile.message ?? 'Avatar upload failed'));
      }
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
    }
  }

  Future<bool> deleteAvatar() async {
    emit(ProfileLoadingState());
    try {
      final profile = await profileRepo.deleteAvatar();
      if (profile.id != -1) {
        emit(UpdateProfileSuccessState(profile));
        return true;
      }
      emit(ProfileErrorState(profile.message ?? 'Avatar removal failed'));
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
    }
    return false;
  }

  void getExperiences() {
    emit(ProfileLoadingState());
    profileRepo.getExperiences().then((list) {
      emit(GetExperiencesSuccessState(list));
    });
  }

  void getEducation() {
    emit(ProfileLoadingState());
    profileRepo.getEducation().then((list) {
      emit(GetEducationSuccessState(list));
    });
  }

  Future<bool> saveExperience(int? id, Map<String, dynamic> data) async {
    try {
      await profileRepo.saveExperience(id, data);
      getProfile();
      return true;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return false;
    }
  }

  Future<bool> deleteExperience(int id) async {
    try {
      await profileRepo.deleteExperience(id);
      getProfile();
      return true;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return false;
    }
  }

  Future<bool> saveEducation(int? id, Map<String, dynamic> data) async {
    try {
      await profileRepo.saveEducation(id, data);
      getProfile();
      return true;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return false;
    }
  }

  Future<bool> deleteEducation(int id) async {
    try {
      await profileRepo.deleteEducation(id);
      getProfile();
      return true;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return false;
    }
  }

  Future<List<SkillModel>> availableSkills() => profileRepo.getSkills();

  Future<bool> attachSkill(int id) async {
    try {
      await profileRepo.attachSkill(id);
      getProfile();
      return true;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return false;
    }
  }

  Future<bool> detachSkill(int id) async {
    try {
      await profileRepo.detachSkill(id);
      getProfile();
      return true;
    } catch (error) {
      emit(ProfileErrorState(error.toString()));
      return false;
    }
  }
}
