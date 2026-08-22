import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/user_model.dart';

void main() {
  test('explicit null email_verified_at is unverified', () {
    final user = UserModel.fromMap({
      'id': 1,
      'name': 'User',
      'email': 'user@example.com',
      'email_verified_at': null,
    });
    expect(user.emailVerified, isFalse);
  });

  test(
    'missing verification field remains compatible with older responses',
    () {
      final user = UserModel.fromMap({
        'id': 1,
        'name': 'User',
        'email': 'user@example.com',
      });
      expect(user.emailVerified, isTrue);
    },
  );
}
