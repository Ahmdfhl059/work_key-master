class ExperienceModel {
  String? message;
  final int id;
  String title;
  String companyName;
  String location;
  String startDate;
  String endDate;
  bool isCurrent;
  String description;

  ExperienceModel({
    this.message,
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.description,
  });

  factory ExperienceModel.initial() => ExperienceModel(
    id: -1,
    message: '',
    title: '',
    companyName: '',
    location: '',
    startDate: '',
    endDate: '',
    isCurrent: false,
    description: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'title': title,
      'company_name': companyName,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent,
      'description': description,
    };
  }

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      companyName: map['company_name']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      isCurrent: map['is_current'] == 1 || map['is_current'] == true,
      description: map['description']?.toString() ?? '',
    );
  }
}
