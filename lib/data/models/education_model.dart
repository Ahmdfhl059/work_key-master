class EducationModel {
  String? message;
  final int id;
  String institution;
  String degree;
  String fieldOfStudy;
  String startDate;
  String endDate;
  String description;

  EducationModel({
    this.message,
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory EducationModel.initial() => EducationModel(
    id: -1,
    message: '',
    institution: '',
    degree: '',
    fieldOfStudy: '',
    startDate: '',
    endDate: '',
    description: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'institution': institution,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
    };
  }

  factory EducationModel.fromMap(Map<String, dynamic> map) {
    return EducationModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      institution: map['institution']?.toString() ?? '',
      degree: map['degree']?.toString() ?? '',
      fieldOfStudy: map['field_of_study']?.toString() ?? '',
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }
}
