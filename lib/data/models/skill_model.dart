class SkillModel {
  String? message;
  final int id;
  String name;
  String level;
  int yearsUsed;

  SkillModel({
    this.message,
    required this.id,
    required this.name,
    required this.level,
    required this.yearsUsed,
  });

  factory SkillModel.initial() =>
      SkillModel(id: -1, message: '', name: '', level: '', yearsUsed: 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'level': level,
      'years_used': yearsUsed,
    };
  }

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      name: map['name']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      level: map['level']?.toString() ?? '',
      yearsUsed: int.tryParse('${map['years_used'] ?? ''}') ?? 0,
    );
  }
}
