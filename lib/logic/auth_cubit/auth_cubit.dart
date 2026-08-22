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
    authRepo
        .login({'email': email, 'password': password})
        .then((user) {
          if (user.id != -1) {
            emit(AuthSuccessState(user));
          } else {
            emit(AuthErrorState(user.message ?? 'Login Failed'));
          }
        })
        .catchError((error) {
          emit(AuthErrorState(error.toString()));
        });
  }

  void registerJobSeeker({
    required String name,
    required String email,
    required String phone, // إضافة الهاتف
    required String password,
    required String passwordConfirmation,
    String? location,
    int? cityId,
  }) {
    print('--- AuthCubit: Starting Register Flow ---');
    emit(AuthLoadingState());
    authRepo
        .registerJobSeeker({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (location?.trim().isNotEmpty == true) 'location': location!.trim(),
          if (cityId != null) 'city_id': cityId,
          'terms_accepted': true, // إرسال الموافقة كما هو مطلوب
        })
        .then((user) {
          if (user.id != -1) {
            emit(AuthSuccessState(user));
          } else {
            emit(AuthErrorState(user.message ?? 'Registration Failed'));
          }
        })
        .catchError((error) {
          emit(AuthErrorState(error.toString()));
        });
  }

  void forgotPassword({required String email}) {
    emit(AuthLoadingState());
    authRepo
        .forgotPassword(email)
        .then((message) {
          emit(ForgotPasswordSuccessState(message));
        })
        .catchError((error) {
          emit(AuthErrorState(error.toString()));
        });
  }

  void resendAccountVerification({
    required String email,
    required String password,
  }) {
    emit(AuthLoadingState());
    authRepo
        .resendAccountVerification(email: email, password: password)
        .then((message) => emit(AccountVerificationCodeSentState(message)))
        .catchError((error) => emit(AuthErrorState(error.toString())));
  }

  Future<void> verifyAccountEmail({
    required String email,
    required String password,
    required String otp,
  }) async {
    emit(AuthLoadingState());
    try {
      await authRepo.verifyAccountEmail(email: email, otp: otp);
      final user = await authRepo.login({'email': email, 'password': password});
      if (user.id != -1 && user.emailVerified) {
        emit(AuthSuccessState(user));
      } else {
        emit(AuthErrorState(user.message ?? 'Email verification failed'));
      }
    } catch (error) {
      emit(AuthErrorState(error.toString()));
    }
  }

  void resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    emit(AuthLoadingState());
    authRepo
        .resetPassword({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        })
        .then((message) {
          emit(ResetPasswordSuccessState(message));
        })
        .catchError((error) {
          emit(AuthErrorState(error.toString()));
        });
  }

  void logout() {
    authRepo.logout().then((value) {
      emit(LogoutSuccessState());
    });
  }

  void logoutAll() {
    emit(AuthLoadingState());
    authRepo
        .logoutAll()
        .then((_) {
          emit(LogoutSuccessState());
        })
        .catchError((error) {
          emit(AuthErrorState(error.toString()));
        });
  }
}
