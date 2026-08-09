class JobSeekerProfileModel {
  String? message;
  final int id;
  String currentStatus;
  int expectedSalary;
  int yearsOfExperience;
  String educationLevel;
  String careerLevel;
  List<String> preferredWorkTypes;
  List<String> preferredJobFields;
  List<String> preferredCities;

  JobSeekerProfileModel({
    this.message,
    required this.id,
    required this.currentStatus,
    required this.expectedSalary,
    required this.yearsOfExperience,
    required this.educationLevel,
    required this.careerLevel,
    required this.preferredWorkTypes,
    required this.preferredJobFields,
    required this.preferredCities,
  });

  factory JobSeekerProfileModel.initial() => JobSeekerProfileModel(
    id: -1,
    message: '',
    currentStatus: '',
    expectedSalary: 0,
    yearsOfExperience: 0,
    educationLevel: '',
    careerLevel: '',
    preferredWorkTypes: [],
    preferredJobFields: [],
    preferredCities: [],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'current_status': currentStatus,
      'expected_salary': expectedSalary,
      'years_of_experience': yearsOfExperience,
      'education_level': educationLevel,
      'career_level': careerLevel,
      'preferred_work_types': preferredWorkTypes,
      'preferred_job_fields': preferredJobFields,
      'preferred_cities': preferredCities,
    };
  }

  factory JobSeekerProfileModel.fromMap(Map<String, dynamic> map) {
    return JobSeekerProfileModel(
      id: map['id'] ?? -1,
      message: map['message'] ?? '',
      currentStatus: map['current_status'] ?? '',
      expectedSalary: map['expected_salary'] ?? 0,
      yearsOfExperience: map['years_of_experience'] ?? 0,
      educationLevel: map['education_level'] ?? '',
      careerLevel: map['career_level'] ?? '',
      preferredWorkTypes: map['preferred_work_types'] != null
          ? List<String>.from(map['preferred_work_types'])
          : [],
      preferredJobFields: map['preferred_job_fields'] != null
          ? List<String>.from(map['preferred_job_fields'])
          : [],
      preferredCities: map['preferred_cities'] != null
          ? List<String>.from(map['preferred_cities'])
          : [],
    );
  }
}
