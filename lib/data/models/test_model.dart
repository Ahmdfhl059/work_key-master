class TestModel {
  String? message;
  final int id;
  String title;
  String description;
  String instructions;
  int durationMinutes;
  int maxScore;
  int passingScore;
  bool isActive;

  TestModel({
    this.message,
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    required this.durationMinutes,
    required this.maxScore,
    required this.passingScore,
    required this.isActive,
  });

  factory TestModel.initial() => TestModel(
    id: -1,
    message: '',
    title: '',
    description: '',
    instructions: '',
    durationMinutes: 0,
    maxScore: 0,
    passingScore: 0,
    isActive: false,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'title': title,
      'description': description,
      'instructions': instructions,
      'duration_minutes': durationMinutes,
      'max_score': maxScore,
      'passing_score': passingScore,
      'is_active': isActive,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      instructions: map['instructions']?.toString() ?? '',
      durationMinutes: int.tryParse('${map['duration_minutes'] ?? ''}') ?? 0,
      maxScore: int.tryParse('${map['max_score'] ?? ''}') ?? 0,
      passingScore: int.tryParse('${map['passing_score'] ?? ''}') ?? 0,
      isActive: map['is_active'] == 1 || map['is_active'] == true,
    );
  }
}
