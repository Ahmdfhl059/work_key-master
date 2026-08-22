import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/screens/profile/cv_review_screen.dart';

void main() {
  test('completed CV decisions advance to final confirmation', () {
    expect(
      isCvReviewComplete({
        'next_action': {'key': 'review_suggestions'},
        'comparison_summary': {'unresolved': 0, 'is_complete': true},
      }),
      isTrue,
    );
  });

  test('pending CV decisions do not advance to final confirmation', () {
    expect(
      isCvReviewComplete({
        'next_action': {'key': 'review_suggestions'},
        'comparison_summary': {'unresolved': 2, 'is_complete': false},
      }),
      isFalse,
    );
  });

  test('CV actions are accepted only when the backend allows them', () {
    final review = {
      'next_action': {'key': 'confirm'},
      'allowed_actions': ['confirm', 'cancel'],
    };

    expect(isCvActionAllowed(review, 'confirm'), isTrue);
    expect(isCvActionAllowed(review, 'generate_suggestions'), isFalse);
    expect(isCvActionAllowed(review, 'ready_for_confirmation'), isFalse);
  });

  test('missing allowed actions never enables a mutating CV request', () {
    expect(isCvActionAllowed(const {}, 'confirm'), isFalse);
  });
}
