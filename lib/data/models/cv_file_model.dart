class CvFileModel {
  String? message;
  final int id;
  String filePath;
  String status;
  String versionLabel;
  bool isPrimary;
  String createdAt;

  CvFileModel({
    this.message,
    required this.id,
    required this.filePath,
    required this.status,
    required this.versionLabel,
    required this.isPrimary,
    required this.createdAt,
  });

  factory CvFileModel.initial() => CvFileModel(
    id: -1,
    message: '',
    filePath: '',
    status: '',
    versionLabel: '',
    isPrimary: false,
    createdAt: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'message': message,
      'status': status,
      'version_label': versionLabel,
      'is_primary': isPrimary,
      'created_at': createdAt,
    };
  }

  factory CvFileModel.fromMap(Map<String, dynamic> map) {
    return CvFileModel(
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      filePath: map['file_path']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      versionLabel: map['version_label']?.toString() ?? '',
      isPrimary: map['is_primary'] == 1 || map['is_primary'] == true,
      createdAt: map['created_at']?.toString() ?? '',
    );
  }
}
