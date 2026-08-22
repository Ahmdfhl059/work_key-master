import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class ProfileApi {
  // تم حذف / من بداية كافة المسارات لضمان الدمج الصحيح مع v1
  Future<Response> getProfile() async {
    print('--- 🌐 API Call: getProfile ---');
    return await RemoteApi.get('profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    print('--- 🌐 API Call: updateProfile ---');
    return await RemoteApi.put('profile', body: data);
  }

  Future<Response> uploadAvatar(FormData formData) async {
    return await RemoteApi.post('profile/avatar', body: formData);
  }

  Future<Response> deleteAvatar() => RemoteApi.delete('profile/avatar');

  Future<Response> previewCurrentCv() => RemoteApi.get('profile/cv/preview');

  Future<Response> downloadCurrentCv() => RemoteApi.get('profile/cv/download');

  Future<Response> getExperiences() async {
    return await RemoteApi.get('profile/experiences');
  }

  Future<Response> addExperience(Map<String, dynamic> data) async {
    return await RemoteApi.post('profile/experiences', body: data);
  }

  Future<Response> updateExperience(int id, Map<String, dynamic> data) async {
    return await RemoteApi.put('profile/experiences/$id', body: data);
  }

  Future<Response> deleteExperience(int id) async {
    return await RemoteApi.delete('profile/experiences/$id');
  }

  Future<Response> getEducation() async {
    return await RemoteApi.get('profile/education');
  }

  Future<Response> addEducation(Map<String, dynamic> data) async {
    return await RemoteApi.post('profile/education', body: data);
  }

  Future<Response> updateEducation(int id, Map<String, dynamic> data) async {
    return await RemoteApi.put('profile/education/$id', body: data);
  }

  Future<Response> deleteEducation(int id) async {
    return await RemoteApi.delete('profile/education/$id');
  }

  Future<Response> getSkills() async {
    return await RemoteApi.get('skills');
  }

  Future<Response> attachSkill(int skillId) async {
    return await RemoteApi.post('profile/skills', body: {'skill_id': skillId});
  }

  Future<Response> detachSkill(int skillId) async {
    return await RemoteApi.delete('profile/skills/$skillId');
  }
}
