import 'test_model.dart';

class TestAssignmentModel {
  String? message;
  final int id;
  String status;
  String scheduledAt;
  String deadline;
  String instructions;
  TestModel test;
  bool canStart;

  TestAssignmentModel({
    this.message,
    required this.id,
    required this.status,
    required this.scheduledAt,
    required this.deadline,
    required this.instructions,
    required this.test,
    required this.canStart,
  });

  factory TestAssignmentModel.initial() => TestAssignmentModel(
    id: -1,
    message: '',
    status: '',
    scheduledAt: '',
    deadline: '',
    instructions: '',
    test: TestModel.initial(),
    canStart: false,
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
      'can_start': canStart,
    };
  }

  factory TestAssignmentModel.fromMap(Map<String, dynamic> map) {
    final nested = map['test'] is Map
        ? Map<String, dynamic>.from(map['test'])
        : map['test_assignment'] is Map
        ? Map<String, dynamic>.from(map['test_assignment'])
        : <String, dynamic>{};
    return TestAssignmentModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message']?.toString() ?? '',
      status: _localizedKey(map['state'] ?? map['status']),
      scheduledAt:
          map['assigned_at']?.toString() ??
          map['scheduled_at']?.toString() ??
          '',
      deadline:
          map['effective_deadline_at']?.toString() ??
          map['deadline_at']?.toString() ??
          map['deadline']?.toString() ??
          '',
      instructions: map['instructions']?.toString() ?? '',
      test: nested.isNotEmpty
          ? TestModel.fromMap(nested)
          : TestModel.fromMap(map),
      canStart: map['can_start'] == true,
    );
  }

  static String _localizedKey(dynamic value) => value is Map
      ? '${value['key'] ?? value['value'] ?? ''}'
      : '${value ?? ''}';
}
