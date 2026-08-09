import '../../data/models/notification_model.dart';

abstract class NotificationsStates {}

class NotificationsInitialState extends NotificationsStates {}

class NotificationsLoadingState extends NotificationsStates {}

class GetNotificationsSuccessState extends NotificationsStates {
  final List<NotificationModel> notifications;
  GetNotificationsSuccessState(this.notifications);
}

class GetUnreadCountSuccessState extends NotificationsStates {
  final int count;
  GetUnreadCountSuccessState(this.count);
}

class NotificationsErrorState extends NotificationsStates {
  final String error;
  NotificationsErrorState(this.error);
}
