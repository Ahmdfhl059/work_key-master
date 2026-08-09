import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/cv_repo.dart';
import 'cv_state.dart';
import 'package:dio/dio.dart';

class CvCubit extends Cubit<CvStates> {
  final CvRepo cvRepo;
  CvCubit(this.cvRepo) : super(CvInitialState());

  static CvCubit get(context) => BlocProvider.of(context);

  // 1. جلب كافة ملفات الـ CV
  void getCvFiles() {
    print('--- 📄 CvCubit: Fetching CV Files ---');
    emit(CvLoadingState());
    cvRepo.getCvFiles().then((list) {
      emit(GetCvFilesSuccessState(list));
    }).catchError((error) {
      emit(CvErrorState(error.toString()));
    });
  }

  // 2. رفع ملف CV جديد (PDF/Word)
  void uploadCv(FormData formData) {
    print('--- 📄 CvCubit: Uploading CV ---');
    emit(CvLoadingState());
    cvRepo.uploadCv(formData).then((model) {
      if (model.id != -1) {
        emit(UploadCvSuccessState(model));
        getCvFiles(); // تحديث القائمة
      } else {
        emit(CvErrorState(model.message ?? 'Upload failed'));
      }
    });
  }

  // 3. جلب المسودة المستخرجة من الـ AI
  void getParsedData(int id) {
    print('--- 📄 CvCubit: Fetching Draft for CV: $id ---');
    emit(CvLoadingState());
    cvRepo.getParsedCv(id).then((data) {
      if (data.isNotEmpty) {
        emit(GetParsedDataSuccessState(data));
      } else {
        emit(CvErrorState("AI Draft is not ready yet. Please refresh."));
      }
    });
  }

  // 4. تعديل المسودة يدوياً (طلبك: "انا فيني اعدل عليها")
  void updateDraftData(int id, Map<String, dynamic> updatedData) {
    print('--- 📄 CvCubit: Updating Draft Data for CV: $id ---');
    emit(CvLoadingState());
    cvRepo.updateDraft(id, updatedData).then((message) {
      getParsedData(id); // إعادة جلب البيانات لرؤية التحديثات
    });
  }

  // 5. تأكيد المراجعة وبدء المقارنة (Suggestions)
  void confirmReview(int id) {
    print('--- 📄 CvCubit: Confirming Draft Review: $id ---');
    emit(CvLoadingState());
    cvRepo.confirmCvReview(id).then((message) {
      generateSuggestions(id); // توليد الاقتراحات فور التأكيد
    });
  }

  // 6. توليد اقتراحات المزامنة (Comparison)
  void generateSuggestions(int id) {
    print('--- 📄 CvCubit: Generating AI Suggestions ---');
    cvRepo.generateSuggestions(id).then((message) {
      emit(CvActionSuccessState(message));
    });
  }

  // 7. جلب قائمة الاقتراحات (ADD/UPDATE/MERGE)
  void getSuggestions(int cvId) {
    emit(CvLoadingState());
    cvRepo.getCvSuggestions(cvId).then((list) {
      emit(GetSuggestionsSuccessState(list));
    });
  }

  // 8. قبول اقتراح محدد
  void acceptSuggestion(int suggestionId, Map<String, dynamic>? editedValue) {
    print('--- 📄 CvCubit: Accepting Suggestion: $suggestionId ---');
    cvRepo.acceptSuggestion(suggestionId, editedValue).then((message) {
      emit(CvActionSuccessState(message));
    });
  }

  // 9. رفض/تجاهل اقتراح
  void rejectSuggestion(int suggestionId, String reason) {
    cvRepo.rejectSuggestion(suggestionId, reason).then((message) {
      emit(CvActionSuccessState(message));
    });
  }

  // 10. المزامنة النهائية (تحديث البروفايل الحقيقي)
  void applyBulk(List<int> ids) {
    emit(CvLoadingState());
    cvRepo.applyBulkSuggestions(ids).then((message) {
      emit(CvActionSuccessState(message));
    });
  }

  // 11. تعيين ملف أساسي
  void makePrimary(int id) {
    emit(CvLoadingState());
    cvRepo.makePrimary(id).then((message) {
      emit(CvActionSuccessState(message));
      getCvFiles();
    });
  }

  // 12. حذف ملف
  void deleteCv(int id) {
    emit(CvLoadingState());
    cvRepo.deleteCv(id).then((message) {
      emit(CvActionSuccessState(message));
      getCvFiles();
    });
  }
}
