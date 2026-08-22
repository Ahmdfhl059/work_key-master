import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/cv_file_model.dart';

void main() {
  test('parses current backend CV contract and original file name', () {
    final cv = CvFileModel.fromMap({
      'id': 12,
      'original_name': 'Karim Backend CV.pdf',
      'extension': 'pdf',
      'size_bytes': 240000,
      'status': {'key': 'parsed', 'label': 'Parsed'},
      'review_status': {'key': 'ready_to_apply', 'label': 'Ready to apply'},
      'stage': {'key': 'final_confirmation', 'label': 'Final confirmation'},
      'next_action': {'key': 'confirm', 'label': 'Confirm'},
      'file_available': true,
      'can_cancel': true,
    });

    expect(cv.displayName, 'Karim Backend CV.pdf');
    expect(cv.parsingStatus.key, 'parsed');
    expect(cv.stage.key, 'final_confirmation');
    expect(cv.canConfirm, isTrue);
    expect(cv.canCancel, isTrue);
  });

  test('nullable CV fields do not break parsing', () {
    final cv = CvFileModel.fromMap({
      'id': 5,
      'original_name': null,
      'status': null,
      'next_action': null,
    });

    expect(cv.displayName, 'CV document');
    expect(cv.statusLabel, 'Uploaded');
    expect(cv.canReview, isFalse);
  });
}
