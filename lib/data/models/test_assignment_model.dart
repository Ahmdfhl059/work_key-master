import 'test_model.dart';

class TestAssignmentModel {
  String? message;
  final int id;
  String status;
  String scheduledAt;
  String deadline;
  String instructions;
  TestModel test;

  TestAssignmentModel({
    this.message,
    required this.id,
    required this.status,
    required this.scheduledAt,
    required this.deadline,
    required this.instructions,
    required this.test,
  });

  factory TestAssignmentModel.initial() => TestAssignmentModel(
    id: -1,
    message: '',
    status: '',
    scheduledAt: '',
    deadline: '',
    instructions: '',
    test: TestModel.initial(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'scheduled_at': scheduledAt,
      'deadline': deadline,
      'instructions': instructions,
      'test': test.toMap(),
    };
  }

  factory TestAssignmentModel.fromMap(Map<String, dynamic> map) {
    return TestAssignmentModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      scheduledAt: map['scheduled_at']?.toString() ?? '',
      deadline: map['deadline']?.toString() ?? '',
      instructions: map['instructions']?.toString() ?? '',
      test: map['test'] is Map
          ? TestModel.fromMap(Map<String, dynamic>.from(map['test']))
          : TestModel.initial(),
    );
  }
}
