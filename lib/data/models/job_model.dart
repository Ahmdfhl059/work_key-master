import 'company_model.dart';
import 'skill_model.dart';

class JobModel {
  String? message;
  final int id;
  String title;
  String description;
  String employmentType;
  String experienceLevel;
  String location;
  String workMode;
  int salaryMin;
  int salaryMax;
  String status;
  String deadline;
  String createdAt;
  CompanyModel company;
  List<SkillModel> skills;
  List<String> requirements; // الحقل الجديد
  List<String> requiredSoftware; // الحقل الجديد
  int? matchScore;

  JobModel({
    this.message,
    required this.id,
    required this.title,
    required this.description,
    required this.employmentType,
    required this.experienceLevel,
    required this.location,
    required this.workMode,
    required this.salaryMin,
    required this.salaryMax,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.company,
    required this.skills,
    required this.requirements,
    required this.requiredSoftware,
    this.matchScore,
  });

  factory JobModel.initial() => JobModel(
    id: -1,
    title: '',
    description: '',
    message: '',
    employmentType: '',
    experienceLevel: '',
    location: '',
    workMode: '',
    salaryMin: 0,
    salaryMax: 0,
    status: '',
    deadline: '',
    createdAt: '',
    company: CompanyModel.initial(),
    skills: [],
    requirements: [],
    requiredSoftware: [],
    matchScore: null,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'message': message,
      'employment_type': employmentType,
      'experience_level': experienceLevel,
      'location': location,
      'work_mode': workMode,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'status': status,
      'deadline': deadline,
      'created_at': createdAt,
      'company': company.toMap(),
      'skills': skills.map((e) => e.toMap()).toList(),
      'requirements': requirements,
      'required_software': requiredSoftware,
      'match_score': matchScore,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      employmentType: _displayValue(map['employment_type']),
      experienceLevel: _displayValue(map['experience_level']),
      location: _displayValue(map['location'] ?? map['city']),
      workMode: _displayValue(map['work_mode']),
      salaryMin: int.tryParse(map['salary_min'].toString()) ?? 0,
      salaryMax: int.tryParse(map['salary_max'].toString()) ?? 0,
      status: _displayValue(map['status']),
      deadline:
          map['application_deadline']?.toString() ??
          map['deadline']?.toString() ??
          '',
      createdAt:
          map['published_at']?.toString() ??
          map['created_at']?.toString() ??
          '',
      company: map['company'] != null
          ? CompanyModel.fromMap(map['company'])
          : CompanyModel.initial(),
      skills: map['skills'] != null
          ? (map['skills'] as List).map((i) => SkillModel.fromMap(i)).toList()
          : [],
      requirements: _stringList(map['requirements']),
      requiredSoftware: _stringList(map['required_software']),
      matchScore: int.tryParse(
        '${map['match_score'] ?? map['score'] ?? (map['match'] is Map ? map['match']['score'] : '')}',
      ),
    );
  }

  static String _displayValue(dynamic value) {
    if (value == null) return '';
    if (value is Map)
      return '${value['value'] ?? value['label'] ?? value['name'] ?? ''}';
    return value.toString();
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return [];
    if (value is List)
      return value
          .map((item) => _displayValue(item))
          .where((item) => item.isNotEmpty)
          .toList();
    final text = _displayValue(value).trim();
    return text.isEmpty ? [] : [text];
  }
}
