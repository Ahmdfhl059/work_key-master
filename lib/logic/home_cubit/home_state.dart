import '../../data/models/home_response_model.dart';

abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeLoadingState extends HomeStates {}

class HomeSuccessState extends HomeStates {
  final HomeResponseModel homeResponse;

  HomeSuccessState(this.homeResponse);
}

class HomeErrorState extends HomeStates {
  final String message;
  final int? statusCode;
  final String? errorCode;

  HomeErrorState(this.message, {this.statusCode, this.errorCode});

  bool get isUnauthorized => statusCode == 401;
  bool get isSuspended => statusCode == 403 &&
      (errorCode?.toUpperCase() == 'USER_SUSPENDED' ||
          message.toUpperCase().contains('USER_SUSPENDED'));
  bool get isForbiddenRole => statusCode == 403 && !isSuspended;
}
