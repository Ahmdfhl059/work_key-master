import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/applications_response_model.dart';
import 'package:work_key/screens/applications/application_status_theme.dart';

void main() {
  test(
    'parses nested application list, counts, action and allowed actions',
    () {
      final response = ApplicationListResponse.fromMap({
        'data': {
          'data': [
            {
              'id': 42,
              'status': {'key': 'test_pending', 'value': 'Test pending'},
              'requires_action': true,
              'allowed_actions': ['view', 'complete_test'],
              'next_action': {
                'type': {'key': 'complete_test', 'value': 'Complete test'},
                'resource_id': 9,
                'deadline': '2026-08-04T10:00:00Z',
              },
              'job_posting': {
                'id': 5,
                'title': 'Backend Developer',
                'work_mode': {'key': 'remote', 'value': 'Remote'},
                'company': {'id': 1, 'name': 'Workey'},
              },
            },
          ],
          'meta': {
            'counts': {
              'all': 12,
              'active': 7,
              'requires_action': 2,
              'completed': 5,
            },
            'current_page': 1,
            'last_page': 2,
            'per_page': 15,
            'total': 20,
          },
        },
      });

      expect(response.items.single.id, 42);
      expect(response.items.single.status.key, 'test_pending');
      expect(response.items.single.nextAction?.resourceId, 9);
      expect(response.items.single.allowedActions, contains('complete_test'));
      expect(response.items.single.job.workMode, 'Remote');
      expect(response.meta.counts.requiresAction, 2);
      expect(response.meta.lastPage, 2);
    },
  );

  test('status theme maps semantic states without relying on labels', () {
    expect(
      ApplicationStatusTheme.from('rejected').foreground,
      isNot(ApplicationStatusTheme.from('accepted').foreground),
    );
  });

  test('parses cover letter, consent and screening answer snapshots', () {
    final application = JobApplication.fromMap({
      'id': 18,
      'cover_letter': 'I am a strong fit.',
      'consent_to_share_profile': true,
      'screening_answers': [
        {
          'question_text': 'Available now?',
          'question_type': {'key': 'boolean', 'value': 'Yes or no'},
          'is_required': true,
          'answer': {'value': true, 'selected_options': []},
        },
        {
          'question_text': 'Choose tools',
          'answer': {
            'value': null,
            'selected_options': [
              {'option_text': 'Flutter'},
              {'option_text': 'Figma'},
            ],
          },
        },
      ],
    });

    expect(application.coverLetter, 'I am a strong fit.');
    expect(application.consentToShareProfile, isTrue);
    expect(application.screeningAnswers.first.answer, 'Yes');
    expect(application.screeningAnswers.last.answer, 'Flutter, Figma');
  });
}
