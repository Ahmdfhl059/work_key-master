import 'package:dio/dio.dart';
import '../api/profile_api.dart';
import '../models/profile_model.dart';
import '../models/experience_model.dart';
import '../models/education_model.dart';
import '../models/skill_model.dart';

class ProfileRepo {
  final ProfileApi _profileApi = ProfileApi();

  Future<ProfileModel> getProfile() async {
    print('--- 👤 ProfileRepo: Fetching Full Profile ---');
    try {
      Response response = await _profileApi.getProfile();
      print('--- 👤 ProfileRepo: Received Data ---');
      print(response.data);

      Map<String, dynamic> responseData = response.data;
      if (responseData['success'] == true) {
        ProfileModel profile = ProfileModel.fromMap(responseData['data']);
        profile.message = responseData['message'];
        return profile;
      } else {
        ProfileModel errorProfile = ProfileModel.initial();
        errorProfile.message = responseData['message'];
        return errorProfile;
      }
    } catch (e) {
      print('--- 👤 ProfileRepo ERROR: $e ---');
      ProfileModel errorProfile = ProfileModel.initial();
      errorProfile.message = e.toString();
      return errorProfile;
    }
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    print('--- 👤 ProfileRepo: Updating Profile with Data: $data ---');
    try {
      Response response = await _profileApi.updateProfile(data);
      Map<String, dynamic> responseData = response.data;
      if (responseData['success'] == true) {
        ProfileModel profile = ProfileModel.fromMap(responseData['data']);
        profile.message = responseData['message'];
        return profile;
      } else {
        ProfileModel errorProfile = ProfileModel.initial();
        errorProfile.message = responseData['message'];
        return errorProfile;
      }
    } catch (e) {
      print('--- 👤 ProfileRepo ERROR during Update: $e ---');
      ProfileModel errorProfile = ProfileModel.initial();
      errorProfile.message = e.toString();
      return errorProfile;
    }
  }

  // --- Experiences ---
  Future<List<ExperienceModel>> getExperiences() async {
    try {
      Response response = await _profileApi.getExperiences();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => ExperienceModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveExperience(int? id, Map<String, dynamic> data) async {
    if (id == null) {
      await _profileApi.addExperience(data);
    } else {
      await _profileApi.updateExperience(id, data);
    }
  }

  Future<void> deleteExperience(int id) async {
    await _profileApi.deleteExperience(id);
  }

  // --- Education ---
  Future<List<EducationModel>> getEducation() async {
    try {
      Response response = await _profileApi.getEducation();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => EducationModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveEducation(int? id, Map<String, dynamic> data) async {
    if (id == null) {
      await _profileApi.addEducation(data);
    } else {
      await _profileApi.updateEducation(id, data);
    }
  }

  Future<void> deleteEducation(int id) async {
    await _profileApi.deleteEducation(id);
  }

  Future<List<SkillModel>> getSkills() async {
    final response = await _profileApi.getSkills();
    final data = response.data['data'];
    final list = data is List
        ? data
        : data is Map && data['data'] is List
        ? data['data'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((item) => SkillModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> attachSkill(int id) async {
    await _profileApi.attachSkill(id);
  }

  Future<void> detachSkill(int id) async {
    await _profileApi.detachSkill(id);
  }
}
