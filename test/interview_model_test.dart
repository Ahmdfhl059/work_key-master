import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/interview_model.dart';

void main() {
  test('parses paginated interview response and localized values', () {
    final response = InterviewListResponse.fromMap({
      'success': true,
      'data': {
        'data': [
          {
            'id': 42,
            'job_application_id': 8,
            'type': {'key': 'technical', 'value': 'Technical interview'},
            'mode': {'key': 'online', 'value': 'Online'},
            'status': {'key': 'scheduled', 'value': 'Scheduled'},
            'candidate_confirmation_status': {
              'key': 'pending',
              'value': 'Pending',
            },
            'candidate_attendance_status': null,
            'scheduled_start_at': '2026-08-13T10:00:00+03:00',
            'duration_minutes': 60,
            'meeting_link': null,
            'job_application': {
              'id': 8,
              'job_posting': {
                'id': 5,
                'title': 'Backend Developer',
                'company': {'id': 2, 'name': 'Workey'},
              },
            },
          },
        ],
        'meta': {
          'current_page': 1,
          'last_page': 2,
          'per_page': 15,
          'total': 16,
        },
      },
    });

    expect(response.items, hasLength(1));
    expect(response.meta.lastPage, 2);
    expect(response.items.first.type.key, 'technical');
    expect(response.items.first.type.label, 'Technical interview');
    expect(response.items.first.jobTitle, 'Backend Developer');
    expect(response.items.first.companyName, 'Workey');
    expect(response.items.first.needsConfirmation, isTrue);
  });

  test('nullable optional fields do not break interview parsing', () {
    final interview = InterviewModel.fromMap({
      'id': '7',
      'type': null,
      'mode': null,
      'status': 'cancelled',
      'scheduled_at': null,
      'job_application': null,
    });

    expect(interview.id, 7);
    expect(interview.scheduledStartAt, isNull);
    expect(interview.meetingLink, isNull);
    expect(interview.jobTitle, 'Interview');
    expect(interview.needsConfirmation, isFalse);
  });
}
