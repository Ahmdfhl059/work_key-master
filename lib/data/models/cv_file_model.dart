class CvLocalizedValue {
  final String key;
  final String label;

  const CvLocalizedValue({this.key = '', this.label = ''});

  factory CvLocalizedValue.fromDynamic(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final key = _text(map['key'] ?? map['value']);
      return CvLocalizedValue(
        key: key,
        label: _text(map['label'] ?? map['value'] ?? map['key']),
      );
    }
    final text = _text(value);
    return CvLocalizedValue(key: text, label: text);
  }
}

class CvFileModel {
  final int id;
  final String originalName;
  final String versionLabel;
  final String? mimeType;
  final String? extension;
  final int sizeBytes;
  final CvLocalizedValue parsingStatus;
  final CvLocalizedValue reviewMode;
  final CvLocalizedValue reviewStatus;
  final CvLocalizedValue stage;
  final CvLocalizedValue nextAction;
  final bool isArchived;
  final bool isCancelled;
  final bool isExpired;
  final bool fileAvailable;
  final bool canCancel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CvFileModel({
    required this.id,
    this.originalName = '',
    this.versionLabel = '',
    this.mimeType,
    this.extension,
    this.sizeBytes = 0,
    this.parsingStatus = const CvLocalizedValue(),
    this.reviewMode = const CvLocalizedValue(),
    this.reviewStatus = const CvLocalizedValue(),
    this.stage = const CvLocalizedValue(),
    this.nextAction = const CvLocalizedValue(),
    this.isArchived = false,
    this.isCancelled = false,
    this.isExpired = false,
    this.fileAvailable = false,
    this.canCancel = false,
    this.createdAt,
    this.updatedAt,
  });

  factory CvFileModel.initial() => const CvFileModel(id: -1);

  factory CvFileModel.fromMap(Map<String, dynamic> map) => CvFileModel(
    id: _integer(map['id'], -1),
    originalName: _text(
      map['original_name'] ?? map['file_name'] ?? map['filename'],
    ),
    versionLabel: _text(map['version_label']),
    mimeType: _nullableText(map['mime_type']),
    extension: _nullableText(map['extension']),
    sizeBytes: _integer(map['size_bytes']),
    parsingStatus: CvLocalizedValue.fromDynamic(
      map['parsing_status'] ?? map['status'],
    ),
    reviewMode: CvLocalizedValue.fromDynamic(map['review_mode']),
    reviewStatus: CvLocalizedValue.fromDynamic(map['review_status']),
    stage: CvLocalizedValue.fromDynamic(map['stage']),
    nextAction: CvLocalizedValue.fromDynamic(map['next_action']),
    isArchived: map['is_archived'] == true,
    isCancelled: map['is_cancelled'] == true,
    isExpired: map['is_expired'] == true,
    fileAvailable: map['file_available'] == true,
    canCancel: map['can_cancel'] == true,
    createdAt: _date(map['created_at']),
    updatedAt: _date(map['updated_at']),
  );

  String get displayName => originalName.isNotEmpty
      ? originalName
      : versionLabel.isNotEmpty
      ? versionLabel
      : 'CV document';

  String get statusLabel {
    if (stage.label.isNotEmpty) return stage.label;
    if (reviewStatus.label.isNotEmpty) return reviewStatus.label;
    if (parsingStatus.label.isNotEmpty) return parsingStatus.label;
    return 'Uploaded';
  }

  bool get canReview => const {
    'review_draft',
    'generate_suggestions',
    'review_suggestions',
    'confirm',
  }.contains(nextAction.key);

  bool get canConfirm => nextAction.key == 'confirm';
}

String _text(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.toLowerCase() == 'null' ? '' : text;
}

String? _nullableText(dynamic value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}

int _integer(dynamic value, [int fallback = 0]) =>
    int.tryParse(_text(value)) ?? fallback;

DateTime? _date(dynamic value) => DateTime.tryParse(_text(value))?.toLocal();
