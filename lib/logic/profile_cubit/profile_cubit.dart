import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/profile_repo.dart';
import 'profile_state.dart';
import '../../data/models/skill_model.dart';

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

  void updateProfile(Map<String, dynamic> data) {
    print('--- 👤 ProfileCubit: Triggering updateProfile ---');
    emit(ProfileLoadingState());
    profileRepo
        .updateProfile(data)
        .then((profile) {
          if (profile.id != -1) {
            emit(UpdateProfileSuccessState(profile));
            getProfile(); // إعادة جلب البيانات لتحديث الواجهة
          } else {
            emit(ProfileErrorState(profile.message ?? 'Update failed'));
          }
        })
        .catchError((error) {
          emit(ProfileErrorState(error.toString()));
        });
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

  Future<void> saveExperience(int? id, Map<String, dynamic> data) async {
    await profileRepo.saveExperience(id, data);
    getProfile();
  }

  Future<void> deleteExperience(int id) async {
    await profileRepo.deleteExperience(id);
    getProfile();
  }

  Future<void> saveEducation(int? id, Map<String, dynamic> data) async {
    await profileRepo.saveEducation(id, data);
    getProfile();
  }

  Future<void> deleteEducation(int id) async {
    await profileRepo.deleteEducation(id);
    getProfile();
  }

  Future<List<SkillModel>> availableSkills() => profileRepo.getSkills();

  Future<void> attachSkill(int id) async {
    await profileRepo.attachSkill(id);
    getProfile();
  }

  Future<void> detachSkill(int id) async {
    await profileRepo.detachSkill(id);
    getProfile();
  }
}
