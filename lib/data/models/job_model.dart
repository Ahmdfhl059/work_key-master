import 'company_model.dart';
import 'skill_model.dart';

class JobModel {
  String? message;
  final int id;
  String title;
  String department;
  String description;
  List<String> responsibilities;
  List<String> benefits;
  String employmentType;
  String experienceLevel;
  String educationLevel;
  String location;
  String cityName;
  String workMode;
  int salaryMin;
  int salaryMax;
  String status;
  String deadline;
  String createdAt;
  CompanyModel company;
  List<SkillModel> skills;
  List<SkillModel> requiredSkills;
  List<SkillModel> niceToHaveSkills;
  List<String> requirements; // الحقل الجديد
  List<String> requiredSoftware; // الحقل الجديد
  num? matchScore;
  bool hasApplied;
  bool canApply;
  int? viewerApplicationId;
  String viewerApplicationStatus;
  bool isNew;
  bool isExpired;
  List<JobScreeningQuestion> screeningQuestions;

  JobModel({
    this.message,
    required this.id,
    required this.title,
    this.department = '',
    required this.description,
    this.responsibilities = const [],
    this.benefits = const [],
    required this.employmentType,
    required this.experienceLevel,
    this.educationLevel = '',
    required this.location,
    this.cityName = '',
    required this.workMode,
    required this.salaryMin,
    required this.salaryMax,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.company,
    required this.skills,
    this.requiredSkills = const [],
    this.niceToHaveSkills = const [],
    required this.requirements,
    required this.requiredSoftware,
    this.matchScore,
    this.hasApplied = false,
    this.canApply = true,
    this.viewerApplicationId,
    this.viewerApplicationStatus = '',
    this.isNew = false,
    this.isExpired = false,
    this.screeningQuestions = const [],
  });

  factory JobModel.initial() => JobModel(
    id: -1,
    title: '',
    department: '',
    description: '',
    responsibilities: [],
    benefits: [],
    message: '',
    employmentType: '',
    experienceLevel: '',
    educationLevel: '',
    location: '',
    cityName: '',
    workMode: '',
    salaryMin: 0,
    salaryMax: 0,
    status: '',
    deadline: '',
    createdAt: '',
    company: CompanyModel.initial(),
    skills: [],
    requiredSkills: [],
    niceToHaveSkills: [],
    requirements: [],
    requiredSoftware: [],
    matchScore: null,
    hasApplied: false,
    canApply: true,
    viewerApplicationId: null,
    viewerApplicationStatus: '',
    isNew: false,
    isExpired: false,
    screeningQuestions: const [],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'description': description,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'message': message,
      'employment_type': employmentType,
      'experience_level': experienceLevel,
      'education_level': educationLevel,
      'location': location,
      'city': {'name': cityName},
      'work_mode': workMode,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'status': status,
      'deadline': deadline,
      'created_at': createdAt,
      'company': company.toMap(),
      'skills': skills.map((e) => e.toMap()).toList(),
      'required_skills': requiredSkills.map((e) => e.toMap()).toList(),
      'nice_to_have_skills': niceToHaveSkills.map((e) => e.toMap()).toList(),
      'requirements': requirements,
      'required_software': requiredSoftware,
      'match_score': matchScore,
      'has_applied': hasApplied,
      'can_apply': canApply,
      'viewer_application_id': viewerApplicationId,
      'viewer_application_status': viewerApplicationStatus,
      'is_new': isNew,
      'is_expired': isExpired,
      'screening_questions': screeningQuestions.map((e) => e.toMap()).toList(),
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    final viewerApplication = map['viewer_application'] is Map
        ? Map<String, dynamic>.from(map['viewer_application'])
        : null;
    final hasApplied =
        map['has_applied'] == true ||
        map['already_applied'] == true ||
        viewerApplication != null ||
        map['application'] != null ||
        map['my_application'] != null;
    final publishedAt =
        map['published_at']?.toString() ?? map['created_at']?.toString() ?? '';
    final deadline =
        map['application_deadline']?.toString() ??
        map['deadline']?.toString() ??
        '';
    return JobModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      title: map['title']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      responsibilities: _stringList(map['responsibilities']),
      benefits: _stringList(map['benefits']),
      message: map['message']?.toString() ?? '',
      employmentType: _displayValue(map['employment_type']),
      experienceLevel: _displayValue(map['experience_level']),
      educationLevel: _displayValue(map['education_level']),
      location: _location(map),
      cityName: _displayValue(map['city']),
      workMode: _displayValue(map['work_mode']),
      salaryMin: int.tryParse(map['salary_min'].toString()) ?? 0,
      salaryMax: int.tryParse(map['salary_max'].toString()) ?? 0,
      status: _displayValue(map['status']),
      deadline: deadline,
      createdAt: publishedAt,
      company: map['company'] != null
          ? CompanyModel.fromMap(map['company'])
          : CompanyModel.initial(),
      skills: map['skills'] != null
          ? (map['skills'] as List).map((i) => SkillModel.fromMap(i)).toList()
          : [],
      requiredSkills: _skillList(map['required_skills']),
      niceToHaveSkills: _skillList(map['nice_to_have_skills']),
      requirements: _stringList(map['requirements']),
      requiredSoftware: _stringList(map['required_software']),
      matchScore: num.tryParse(
        '${map['match_score'] ?? map['score'] ?? (map['match'] is Map ? map['match']['score'] : '')}',
      ),
      hasApplied: hasApplied,
      canApply: hasApplied
          ? false
          : map['viewer_can_apply'] is bool
          ? map['viewer_can_apply'] == true
          : map['can_apply'] is bool
          ? map['can_apply'] == true
          : map['is_accepting_applications'] is bool
          ? map['is_accepting_applications'] == true
          : true,
      viewerApplicationId: int.tryParse(
        '${viewerApplication?['id'] ?? map['viewer_application_id'] ?? ''}',
      ),
      viewerApplicationStatus: _displayValue(
        viewerApplication?['status'] ?? map['viewer_application_status'],
      ),
      isNew: map['is_new'] == true || _publishedRecently(publishedAt),
      isExpired:
          map['is_application_deadline_passed'] == true ||
          map['is_accepting_applications'] == false ||
          map['can_apply'] == false ||
          (map['viewer_can_apply'] == false && viewerApplication == null) ||
          _deadlinePassed(deadline),
      screeningQuestions: map['screening_questions'] is List
          ? (map['screening_questions'] as List)
                .whereType<Map>()
                .map(
                  (e) => JobScreeningQuestion.fromMap(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }

  static String _displayValue(dynamic value) {
    if (value == null) return '';
    if (value is Map)
      return '${value['value'] ?? value['label'] ?? value['name'] ?? ''}';
    return value.toString();
  }

  static bool _publishedRecently(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return false;
    final age = DateTime.now().difference(date);
    return !age.isNegative && age <= const Duration(days: 3);
  }

  static bool _deadlinePassed(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    return date != null && date.isBefore(DateTime.now());
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

  static List<SkillModel> _skillList(dynamic value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => SkillModel.fromMap(Map<String, dynamic>.from(item)))
            .toList()
      : const [];

  static String _location(Map<String, dynamic> map) {
    final location = _displayValue(map['location']).trim();
    final city = _displayValue(map['city']).trim();
    if (location.isEmpty) return city;
    if (city.isEmpty || location.toLowerCase().contains(city.toLowerCase())) {
      return location;
    }
    return '$location • $city';
  }
}

class JobScreeningQuestion {
  final int id;
  final String text;
  final String type;
  final bool required;
  final List<JobScreeningOption> options;

  const JobScreeningQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.required,
    this.options = const [],
  });

  factory JobScreeningQuestion.fromMap(Map<String, dynamic> map) =>
      JobScreeningQuestion(
        id: int.tryParse('${map['id']}') ?? -1,
        text: '${map['question_text'] ?? map['question'] ?? ''}',
        type: _key(map['question_type'] ?? map['type']),
        required: map['is_required'] == true || map['required'] == true,
        options: map['options'] is List
            ? (map['options'] as List)
                  .whereType<Map>()
                  .map(
                    (e) => JobScreeningOption.fromMap(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
            : const [],
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'question_text': text,
    'question_type': type,
    'is_required': required,
    'options': options.map((e) => e.toMap()).toList(),
  };

  static String _key(dynamic value) => value is Map
      ? '${value['key'] ?? value['value'] ?? ''}'
      : '${value ?? ''}';
}

class JobScreeningOption {
  final int id;
  final String text;

  const JobScreeningOption({required this.id, required this.text});

  factory JobScreeningOption.fromMap(Map<String, dynamic> map) =>
      JobScreeningOption(
        id: int.tryParse('${map['id']}') ?? -1,
        text: '${map['option_text'] ?? map['label'] ?? map['text'] ?? ''}',
      );

  Map<String, dynamic> toMap() => {'id': id, 'option_text': text};
}
