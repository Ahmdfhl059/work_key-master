import '../../data/models/application_model.dart';

abstract class ApplicationStates {}

class ApplicationInitialState extends ApplicationStates {}

class ApplicationLoadingState extends ApplicationStates {}

class GetApplicationsSuccessState extends ApplicationStates {
  final List<ApplicationModel> applications;
  GetApplicationsSuccessState(this.applications);
}

class GetApplicationDetailsSuccessState extends ApplicationStates {
  final ApplicationModel application;
  GetApplicationDetailsSuccessState(this.application);
}

class ApplicationActionSuccessState extends ApplicationStates {
  final String message;
  ApplicationActionSuccessState(this.message);
}

class ApplicationErrorState extends ApplicationStates {
  final String error;
  ApplicationErrorState(this.error);
}
