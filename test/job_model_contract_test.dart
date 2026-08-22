import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/job_model.dart';

void main() {
  test('parses viewer application and backend screening question contract', () {
    final job = JobModel.fromMap({
      'id': 12,
      'title': 'Backend Engineer',
      'published_at': DateTime.now()
          .subtract(const Duration(hours: 3))
          .toIso8601String(),
      'application_deadline': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      'viewer_application': {'id': 99},
      'screening_questions': [
        {
          'id': 10,
          'question_text': 'Are you available?',
          'question_type': {'key': 'boolean', 'value': 'Yes or no'},
          'is_required': true,
          'options': [],
        },
        {
          'id': 11,
          'question_text': 'Choose tools',
          'question_type': {
            'key': 'multiple_choice',
            'value': 'Multiple choice',
          },
          'is_required': true,
          'options': [
            {'id': 6, 'option_text': 'Flutter'},
          ],
        },
      ],
    });

    expect(job.hasApplied, isTrue);
    expect(job.canApply, isFalse);
    expect(job.viewerApplicationId, 99);
    expect(job.isNew, isTrue);
    expect(job.isExpired, isTrue);
    expect(job.screeningQuestions, hasLength(2));
    expect(job.screeningQuestions.first.type, 'boolean');
    expect(job.screeningQuestions.last.options.single.text, 'Flutter');
  });

  test('keeps all job detail fields returned by JobPostingResource', () {
    final job = JobModel.fromMap({
      'id': 7,
      'title': 'Product Designer',
      'department': 'Design',
      'description': 'Build accessible products.',
      'responsibilities': ['Research users', 'Create prototypes'],
      'requirements': ['Three years of experience'],
      'benefits': ['Flexible hours'],
      'education_level': {'key': 'bachelor', 'value': 'Bachelor degree'},
      'location': 'Al-Mazzeh',
      'city': {'id': 2, 'name': 'Damascus'},
      'company': {
        'id': 3,
        'name': 'Workey',
        'logo_url': '/storage/company/logo.png',
        'cover_image_url': '/storage/company/cover.jpg',
      },
      'required_skills': [
        {'id': 1, 'name': 'Figma'},
      ],
      'nice_to_have_skills': [
        {'id': 2, 'name': 'Flutter'},
      ],
    });

    expect(job.department, 'Design');
    expect(job.responsibilities, hasLength(2));
    expect(job.benefits.single, 'Flexible hours');
    expect(job.educationLevel, 'Bachelor degree');
    expect(job.cityName, 'Damascus');
    expect(job.location, 'Al-Mazzeh • Damascus');
    expect(job.requiredSkills.single.name, 'Figma');
    expect(job.niceToHaveSkills.single.name, 'Flutter');
    expect(job.company.logo, endsWith('/storage/company/logo.png'));
    expect(job.company.coverImage, endsWith('/storage/company/cover.jpg'));
  });

  test('keeps fractional recommendation scores returned by the backend', () {
    final job = JobModel.fromMap({
      'id': 8,
      'title': 'Flutter Developer',
      'score': 87.25,
    });

    expect(job.matchScore, 87.25);
  });
}
