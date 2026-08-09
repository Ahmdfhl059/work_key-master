import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/notifications_repo.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsStates> {
  final NotificationsRepo notificationsRepo;
  NotificationsCubit(this.notificationsRepo) : super(NotificationsInitialState());

  static NotificationsCubit get(context) => BlocProvider.of(context);

  void getNotifications() {
    emit(NotificationsLoadingState());
    notificationsRepo.getNotifications().then((list) {
      emit(GetNotificationsSuccessState(list));
    }).catchError((error) {
      emit(NotificationsErrorState(error.toString()));
    });
  }

  void getUnreadCount() {
    notificationsRepo.getUnreadCount().then((count) {
      emit(GetUnreadCountSuccessState(count));
    });
  }

  void markAsRead(int id) {
    notificationsRepo.markAsRead(id).then((value) {
      getNotifications(); // تحديث القائمة بعد القراءة
      getUnreadCount();   // تحديث العداد
    });
  }
}
