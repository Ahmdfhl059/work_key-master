import '../../data/models/cv_file_model.dart';

class CvState {
  final List<CvFileModel> files;
  final bool loading;
  final int? busyFileId;
  final String? error;
  final String? message;
  final bool profileChanged;

  const CvState({
    this.files = const [],
    this.loading = false,
    this.busyFileId,
    this.error,
    this.message,
    this.profileChanged = false,
  });

  CvState copyWith({
    List<CvFileModel>? files,
    bool? loading,
    int? busyFileId,
    bool clearBusyFile = false,
    String? error,
    bool clearError = false,
    String? message,
    bool clearMessage = false,
    bool? profileChanged,
  }) => CvState(
    files: files ?? this.files,
    loading: loading ?? this.loading,
    busyFileId: clearBusyFile ? null : busyFileId ?? this.busyFileId,
    error: clearError ? null : error ?? this.error,
    message: clearMessage ? null : message ?? this.message,
    profileChanged: profileChanged ?? this.profileChanged,
  );
}
