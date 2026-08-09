import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepo authRepo;
  AuthCubit(this.authRepo) : super(AuthInitialState());

  static AuthCubit get(context) => BlocProvider.of(context);

  void login({required String email, required String password}) {
    print('--- AuthCubit: Starting Login Flow ---');
    emit(AuthLoadingState());
    authRepo.login({'email': email, 'password': password}).then((user) {
      if (user.id != -1) {
        emit(AuthSuccessState(user));
      } else {
        emit(AuthErrorState(user.message ?? 'Login Failed'));
      }
    }).catchError((error) {
      emit(AuthErrorState(error.toString()));
    });
  }

  void registerJobSeeker({
    required String name,
    required String email,
    required String phone, // إضافة الهاتف
    required String password,
    required String passwordConfirmation,
  }) {
    print('--- AuthCubit: Starting Register Flow ---');
    emit(AuthLoadingState());
    authRepo.registerJobSeeker({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'terms_accepted': true, // إرسال الموافقة كما هو مطلوب
    }).then((user) {
      if (user.id != -1) {
        emit(AuthSuccessState(user));
      } else {
        emit(AuthErrorState(user.message ?? 'Registration Failed'));
      }
    }).catchError((error) {
      emit(AuthErrorState(error.toString()));
    });
  }

  void forgotPassword({required String email}) {
    emit(AuthLoadingState());
    authRepo.forgotPassword(email).then((message) {
      emit(ForgotPasswordSuccessState(message));
    }).catchError((error) {
      emit(AuthErrorState(error.toString()));
    });
  }

  void resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    emit(AuthLoadingState());
    authRepo.resetPassword({
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }).then((message) {
      emit(ResetPasswordSuccessState(message));
    }).catchError((error) {
      emit(AuthErrorState(error.toString()));
    });
  }

  void logout() {
    authRepo.logout().then((value) {
      emit(LogoutSuccessState());
    });
  }
}
