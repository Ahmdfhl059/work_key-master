import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/cv_repo.dart';
import 'cv_state.dart';

class CvCubit extends Cubit<CvState> {
  final CvRepo cvRepo;

  CvCubit(this.cvRepo) : super(const CvState());

  static CvCubit get(dynamic context) => BlocProvider.of<CvCubit>(context);

  Future<void> getCvFiles({bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          clearMessage: true,
          profileChanged: false,
        ),
      );
    }
    try {
      final files = await cvRepo.getCvFiles();
      emit(
        state.copyWith(
          files: files,
          loading: false,
          clearBusyFile: true,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          clearBusyFile: true,
          error: 'We could not load your CV. Please try again.',
        ),
      );
    }
  }

  Future<void> uploadCv(FormData formData) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearMessage: true,
        profileChanged: false,
      ),
    );
    try {
      final uploaded = await cvRepo.uploadCv(formData);
      final merged = [
        uploaded,
        ...state.files.where((file) => file.id != uploaded.id),
      ];
      emit(
        state.copyWith(
          files: merged,
          loading: false,
          message: 'CV uploaded. Review and confirm it to update your profile.',
        ),
      );
      await getCvFiles(showLoading: false);
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          error: 'CV upload failed. Please check the file and try again.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getReview(int id) => cvRepo.getCvReview(id);

  Future<Map<String, dynamic>> getParsedData(int id) => cvRepo.getParsedCv(id);

  Future<void> generateSuggestions(int id) async {
    emit(state.copyWith(busyFileId: id, clearError: true));
    try {
      await cvRepo.generateSuggestions(id);
      await getCvFiles(showLoading: false);
    } catch (_) {
      emit(
        state.copyWith(
          clearBusyFile: true,
          error: 'We could not prepare the CV differences.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> acceptSuggestion(
    int suggestionId,
    Map<String, dynamic>? editedValue,
  ) async {
    final suggestion = await cvRepo.acceptSuggestion(suggestionId, editedValue);
    emit(
      state.copyWith(
        profileChanged: false,
        message: 'CV decision saved.',
        clearError: true,
      ),
    );
    return suggestion;
  }

  Future<Map<String, dynamic>> rejectSuggestion(
    int suggestionId,
    String reason,
  ) => cvRepo.rejectSuggestion(suggestionId, reason);

  Future<Map<String, dynamic>> decideBulkSuggestions(
    int cvFileId,
    List<int> ids,
    String decision,
  ) => cvRepo.decideBulkSuggestions(cvFileId, ids, decision);

  Future<Map<String, dynamic>?> confirmReview(int id) async {
    emit(state.copyWith(busyFileId: id, clearError: true));
    try {
      final confirmation = await cvRepo.confirmCvReview(id);
      await getCvFiles(showLoading: false);
      emit(
        state.copyWith(
          clearBusyFile: true,
          clearError: true,
          message: 'CV confirmed and your profile was updated.',
          profileChanged: true,
        ),
      );
      return confirmation;
    } catch (_) {
      emit(
        state.copyWith(
          clearBusyFile: true,
          error: 'CV confirmation failed. Complete the required review first.',
        ),
      );
      return null;
    }
  }

  Future<void> cancelCv(int id) async {
    emit(state.copyWith(busyFileId: id, clearError: true));
    try {
      await cvRepo.cancelCv(id);
      emit(
        state.copyWith(
          files: state.files.where((file) => file.id != id).toList(),
          clearBusyFile: true,
          message: 'cv.delete_success',
        ),
      );
      await getCvFiles(showLoading: false);
    } catch (_) {
      emit(state.copyWith(clearBusyFile: true, error: 'cv.delete_error'));
    }
  }

  void consumeFeedback() => emit(
    state.copyWith(clearError: true, clearMessage: true, profileChanged: false),
  );
}
