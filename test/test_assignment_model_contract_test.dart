import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/test_assignment_model.dart';

void main() {
  test('parses candidate assigned test contract', () {
    final assignment = TestAssignmentModel.fromMap({
      'id': 7,
      'assigned_at': '2026-08-19T10:00:00Z',
      'deadline_at': '2026-08-20T10:00:00Z',
      'effective_deadline_at': '2026-08-20T09:30:00Z',
      'can_start': true,
      'state': {'key': 'not_started', 'value': 'Not started'},
      'test': {'id': 4, 'title': 'Flutter test', 'duration_minutes': 30},
    });

    expect(assignment.status, 'not_started');
    expect(assignment.canStart, isTrue);
    expect(assignment.deadline, '2026-08-20T09:30:00Z');
    expect(assignment.test.title, 'Flutter test');
  });
}
