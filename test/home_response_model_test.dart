import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/home_response_model.dart';

void main() {
  group('HomeResponseModel.fromMap', () {
    test('parses an authenticated payload', () {
      final payload = {
        'success': true,
        'message': 'Home data retrieved successfully.',
        'data': {
          'viewer': {
            'type': 'job_seeker',
            'is_authenticated': true,
            'name': 'أحمد',
            'avatar_url': 'https://example.com/avatar.png',
          },
          'profile_completeness': {
            'percentage': 78,
            'is_complete': false,
            'missing_items_count': 2,
            'next_item': {
              'key': 'professional_summary',
              'label': 'أضف ملخصك المهني',
              'route': '/profile/edit',
            },
          },
          'required_action': {
            'type': 'interview',
            'title': 'لديك مقابلة غدًا',
            'subtitle': 'مقابلة تقنية',
            'date_time': '2026-08-01T10:00:00+03:00',
            'action': {
              'label': 'عرض التفاصيل',
              'route': '/interviews/42',
            },
          },
          'recommended_jobs': [
            {'id': 18, 'title': 'Backend Developer'}
          ],
          'featured_companies': [],
          'latest_jobs': [],
          'meta': {'recommendations_available': false},
        },
      };

      final home = HomeResponseModel.fromMap(payload);

      expect(home.viewer?.type, 'job_seeker');
      expect(home.viewer?.isAuthenticated, isTrue);
      expect(home.profileCompleteness?.percentage, 78);
      expect(home.requiredAction?.title, 'لديك مقابلة غدًا');
      expect(home.recommendedJobs.length, 1);
      expect(home.latestJobs.isEmpty, isTrue);
      expect(home.recommendationsAvailable, isFalse);
    });

    test('uses semantic required action target instead of its display text', () {
      final home = HomeResponseModel.fromMap({
        'success': true,
        'data': {
          'viewer': {'type': 'job_seeker', 'is_authenticated': true},
          'required_action': {
            'type': 'anything',
            'title': 'نص قابل للتغيير',
            'target': {'type': 'test_assignment', 'id': 73},
          },
        },
      });

      expect(home.requiredAction?.target?.type, 'test_assignment');
      expect(home.requiredAction?.target?.id, '73');
      expect(home.requiredAction?.resolvedRoute, '/tests/73');
    });

    test('extracts readable text from structured job values', () {
      final home = HomeResponseModel.fromMap({
        'success': true,
        'data': {
          'viewer': {'type': 'job_seeker', 'is_authenticated': true},
          'recommended_jobs': [
            {
              'id': 1,
              'title': {'key': 'job_title', 'value': 'Backend Developer'},
              'location': {'key': 'location', 'label': 'Damascus'},
              'match': {
                'score': 90,
                'reasons': [
                  {'key': 'skills', 'value': 'Four matching skills', 'result': true}
                ],
              },
            }
          ],
        },
      });

      final job = home.recommendedJobs.single;
      expect(job.title, 'Backend Developer');
      expect(job.location, 'Damascus');
      expect(job.matchReasons, ['Four matching skills']);
      expect(job.matchReasons.single, isNot(contains('key')));
    });

    test('parses a guest payload', () {
      final payload = {
        'success': true,
        'data': {
          'viewer': {
            'type': 'guest',
            'is_authenticated': false,
          },
          'hero': {
            'title': 'وظيفتك المناسبة تبدأ من هنا',
            'description': 'اكتشف فرصًا تناسب مهاراتك وطموحاتك.',
            'primary_action': {
              'label': 'إنشاء حساب',
              'route': '/register',
            },
            'secondary_action': {
              'label': 'تسجيل الدخول',
              'route': '/login',
            },
          },
          'latest_jobs': [],
          'featured_companies': [],
          'app_features': [
            {
              'key': 'smart_recommendations',
              'title': 'توصيات ذكية',
              'description': 'وظائف تناسب مهاراتك وخبرتك',
            }
          ],
        },
      };

      final home = HomeResponseModel.fromMap(payload);

      expect(home.viewer?.type, 'guest');
      expect(home.viewer?.isAuthenticated, isFalse);
      expect(home.hero?.title, 'وظيفتك المناسبة تبدأ من هنا');
      expect(home.appFeatures.length, 1);
      expect(home.isGuest, isTrue);
    });
  });
}
