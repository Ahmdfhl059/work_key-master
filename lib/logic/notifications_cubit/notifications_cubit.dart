import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/notifications_repo.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsStates> {
  final NotificationsRepo notificationsRepo;
  int unreadCount = 0;
  NotificationsCubit(this.notificationsRepo)
    : super(NotificationsInitialState());

  static NotificationsCubit get(dynamic context) => BlocProvider.of(context);

  Future<void> getNotifications() async {
    emit(NotificationsLoadingState());
    try {
      final list = await notificationsRepo.getNotifications();
      emit(GetNotificationsSuccessState(list));
    } catch (error) {
      emit(NotificationsErrorState(error.toString()));
    }
  }

  void getUnreadCount() {
    notificationsRepo.getUnreadCount().then((count) {
      unreadCount = count;
      emit(GetUnreadCountSuccessState(count));
    });
  }

  Future<void> markAsRead(int id) async {
    try {
      await notificationsRepo.markAsRead(id);
      await getNotifications();
      getUnreadCount();
    } catch (error) {
      emit(NotificationsErrorState(error.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationsRepo.markAllAsRead();
      await getNotifications();
      getUnreadCount();
    } catch (error) {
      emit(NotificationsErrorState(error.toString()));
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await notificationsRepo.deleteNotification(id);
      await getNotifications();
      getUnreadCount();
    } catch (error) {
      emit(NotificationsErrorState(error.toString()));
    }
  }
}
