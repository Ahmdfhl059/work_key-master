import 'education_model.dart';
import 'experience_model.dart';
import 'skill_model.dart';
import 'user_model.dart';

class ProfileModel {
  String? message;
  final int id;
  String headline;
  String summary;
  String location;
  String phone;
  String portfolioUrl;
  String linkedinUrl;
  String githubUrl;
  int expectedSalary;
  int yearsOfExperience;

  // حقول الأهداف المهنية
  String currentStatus;
  String educationLevel;
  String careerLevel;
  List<String> preferredWorkTypes;
  List<String> preferredJobFields;
  List<String> preferredCities;

  UserModel user;
  List<ExperienceModel> experiences;
  List<EducationModel> education;
  List<SkillModel> skills;

  ProfileModel({
    this.message,
    required this.id,
    required this.headline,
    required this.summary,
    required this.location,
    required this.phone,
    required this.portfolioUrl,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.expectedSalary,
    required this.yearsOfExperience,
    required this.currentStatus,
    required this.educationLevel,
    required this.careerLevel,
    required this.preferredWorkTypes,
    required this.preferredJobFields,
    required this.preferredCities,
    required this.user,
    required this.experiences,
    required this.education,
    required this.skills,
  });

  factory ProfileModel.initial() => ProfileModel(
    id: -1,
    message: '',
    headline: '',
    summary: '',
    location: '',
    phone: '',
    portfolioUrl: '',
    linkedinUrl: '',
    githubUrl: '',
    expectedSalary: 0,
    yearsOfExperience: 0,
    currentStatus: 'Looking for a job',
    educationLevel: 'Bachelor Degree',
    careerLevel: 'Mid Level',
    preferredWorkTypes: [],
    preferredJobFields: [],
    preferredCities: [],
    user: UserModel.initial(),
    experiences: [],
    education: [],
    skills: [],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'headline': headline,
      'summary': summary,
      'location': location,
      'phone': phone,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'expected_salary': expectedSalary,
      'years_of_experience': yearsOfExperience,
      'current_status': currentStatus,
      'education_level': educationLevel,
      'career_level': careerLevel,
      'preferred_work_types': preferredWorkTypes,
      'preferred_job_fields': preferredJobFields,
      'preferred_cities': preferredCities,
      'user': user.toMap(),
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'skills': skills.map((e) => e.toMap()).toList(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      message: map['message']?.toString() ?? '',
      headline: map['headline']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      portfolioUrl: map['portfolio_url']?.toString() ?? '',
      linkedinUrl: map['linkedin_url']?.toString() ?? '',
      githubUrl: map['github_url']?.toString() ?? '',
      expectedSalary: int.tryParse(map['expected_salary'].toString()) ?? 0,
      yearsOfExperience:
          int.tryParse(map['years_of_experience'].toString()) ?? 0,

      currentStatus: map['current_status']?.toString() ?? 'Looking for a job',
      educationLevel: map['education_level']?.toString() ?? 'Bachelor Degree',
      careerLevel: map['career_level']?.toString() ?? 'Mid Level',
      preferredWorkTypes: _safeStringList(map['preferred_work_types']),
      preferredJobFields: _safeStringList(map['preferred_job_fields']),
      preferredCities: _safeStringList(map['preferred_cities']),

      user: map['user'] != null
          ? UserModel.fromMap(map['user'])
          : UserModel.initial(),
      experiences: map['experiences'] is List
          ? (map['experiences'] as List)
                .whereType<Map>()
                .map(
                  (e) => ExperienceModel.fromMap(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],
      education: map['education'] is List
          ? (map['education'] as List)
                .whereType<Map>()
                .map(
                  (e) => EducationModel.fromMap(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],
      skills: map['skills'] is List
          ? (map['skills'] as List)
                .whereType<Map>()
                .map((e) => SkillModel.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : [],
    );
  }

  static List<String> _safeStringList(dynamic value) {
    if (value is! List) return [];
    return value
        .map((item) {
          if (item is Map)
            return '${item['value'] ?? item['label'] ?? item['name'] ?? ''}';
          return item?.toString() ?? '';
        })
        .where((item) => item.trim().isNotEmpty && item.toLowerCase() != 'null')
        .toList();
  }
}
