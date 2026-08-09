import '../../data/models/user_model.dart';

abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class AuthLoadingState extends AuthStates {}

class AuthSuccessState extends AuthStates {
  final UserModel userModel;
  AuthSuccessState(this.userModel);
}

class AuthErrorState extends AuthStates {
  final String error;
  AuthErrorState(this.error);
}

class LogoutSuccessState extends AuthStates {}

class ForgotPasswordSuccessState extends AuthStates {
  final String message;
  ForgotPasswordSuccessState(this.message);
}

class ResetPasswordSuccessState extends AuthStates {
  final String message;
  ResetPasswordSuccessState(this.message);
}
