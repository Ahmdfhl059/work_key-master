import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/profile_api.dart';
import '../models/profile_model.dart';
import '../models/experience_model.dart';
import '../models/education_model.dart';
import '../models/skill_model.dart';

class ProfileRepo {
  final ProfileApi _profileApi;

  ProfileRepo({ProfileApi? profileApi})
    : _profileApi = profileApi ?? ProfileApi();

  Future<ProfileModel> getProfile() async {
    print('--- 👤 ProfileRepo: Fetching Full Profile ---');
    try {
      Response response = await _profileApi.getProfile();
      print('--- 👤 ProfileRepo: Received Data ---');
      _debugProfile('GET /profile', response.data);

      Map<String, dynamic> responseData = response.data;
      if (responseData['success'] == true) {
        ProfileModel profile = ProfileModel.fromMap(
          _profilePayload(responseData['data']),
        );
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
      _debugProfile('PUT /profile', response.data);
      Map<String, dynamic> responseData = response.data;
      if (responseData['success'] == true) {
        // PUT /profile returns the complete canonical ProfilePageResource.
        // Using it directly avoids turning a successful update into a false
        // failure when a second GET is slow or temporarily unavailable.
        final profile = ProfileModel.fromMap(
          _profilePayload(responseData['data']),
        );
        profile.message = responseData['message']?.toString();
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

  void _debugProfile(String source, dynamic payload) {
    if (!kDebugMode) return;
    try {
      debugPrint('--- 👤 FULL PROFILE [$source] ---');
      debugPrint(jsonEncode(payload));
      debugPrint('--- 👤 END FULL PROFILE ---');
    } catch (_) {
      debugPrint('FULL PROFILE [$source]: $payload');
    }
  }

  Future<ProfileModel> uploadAvatar(String path) async {
    final response = await _profileApi.uploadAvatar(
      // The backend validator expects `image`. Unknown multipart fields are
      // ignored while still returning 200, which previously caused a false
      // success with a null avatar_url.
      FormData.fromMap({'image': await MultipartFile.fromFile(path)}),
    );
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] != true) {
      final profile = ProfileModel.initial();
      profile.message = root['message']?.toString() ?? 'Avatar upload failed';
      return profile;
    }
    // Avatar responses may contain only the updated user. Reload the complete
    // profile so all sections remain available in the UI.
    return getProfile();
  }

  Future<ProfileModel> deleteAvatar() async {
    final response = await _profileApi.deleteAvatar();
    final root = response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : <String, dynamic>{};
    if (root['success'] != true) {
      final result = ProfileModel.initial();
      result.message = root['message']?.toString() ?? 'Avatar removal failed';
      return result;
    }
    return getProfile();
  }

  Map<String, dynamic> _profilePayload(dynamic value) {
    final root = value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
    Map<String, dynamic> profile = Map<String, dynamic>.from(root);
    for (final key in const ['data', 'job_seeker_profile', 'profile']) {
      final nested = profile[key];
      if (nested is Map) {
        profile = Map<String, dynamic>.from(nested);
      }
    }
    final userSource = profile['user'] is Map
        ? Map<String, dynamic>.from(profile['user'] as Map)
        : root['user'] is Map
        ? Map<String, dynamic>.from(root['user'] as Map)
        : <String, dynamic>{};
    final identity = profile['identity'] is Map
        ? Map<String, dynamic>.from(profile['identity'] as Map)
        : <String, dynamic>{};
    final professional = profile['professional_profile'] is Map
        ? Map<String, dynamic>.from(profile['professional_profile'] as Map)
        : <String, dynamic>{};
    final career = profile['career_summary'] is Map
        ? Map<String, dynamic>.from(profile['career_summary'] as Map)
        : <String, dynamic>{};
    final identityAvatar = identity['avatar'] is Map
        ? Map<String, dynamic>.from(identity['avatar'] as Map)
        : <String, dynamic>{};
    for (final key in const [
      'name',
      'email',
      'phone',
      'avatar_url',
      'profile_image_url',
      'profile_photo_url',
      'profile_picture_url',
      'avatar',
      'image_url',
      'image',
    ]) {
      userSource[key] ??= profile[key] ?? identity[key] ?? root[key];
    }
    userSource['avatar_url'] ??= identityAvatar['url'];
    for (final key in const [
      'summary',
      'phone',
      'portfolio_url',
      'linkedin_url',
      'github_url',
    ]) {
      profile[key] ??= professional[key];
    }
    profile['headline'] ??= identity['headline'];
    profile['location'] ??= identity['location'] ?? identity['city'];
    profile['years_of_experience'] ??= career['years_of_experience'];
    final availability = career['availability'];
    if (availability is Map) {
      profile['current_status'] ??=
          availability['status'] ?? availability['display_label'];
    }
    profile['user'] = userSource;
    return profile;
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
