import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/api/cv_api.dart';

void main() {
  group('CV suggestion accept payload', () {
    test('omits edited_value when the CV value is selected unchanged', () {
      final body = buildAcceptSuggestionBody(null);

      expect(body, isEmpty);
      expect(body.containsKey('edited_value'), isFalse);
    });

    test('never turns an empty edit into an empty structured value', () {
      final body = buildAcceptSuggestionBody({});

      expect(body, isEmpty);
      expect(body.containsKey('edited_value'), isFalse);
    });

    test('includes edited_value only for a real user edit', () {
      final body = buildAcceptSuggestionBody({
        'title': 'Flutter Developer',
        'company_name': 'Work Key',
      });

      expect(body['edited_value'], {
        'title': 'Flutter Developer',
        'company_name': 'Work Key',
      });
    });
  });
}
