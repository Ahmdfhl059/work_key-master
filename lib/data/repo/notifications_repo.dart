import 'package:dio/dio.dart';
import '../api/notifications_api.dart';
import '../models/notification_model.dart';

class NotificationsRepo {
  final NotificationsApi _notificationsApi = NotificationsApi();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      Response response = await _notificationsApi.getNotifications();
      if (response.data['success'] == true) {
        return (response.data['data']['data'] as List)
            .map((e) => NotificationModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      Response response = await _notificationsApi.getUnreadCount();
      if (response.data['success'] == true) {
        return response.data['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String> markAsRead(int id) async {
    try {
      Response response = await _notificationsApi.markAsRead(id);
      return response.data['message'] ?? 'Marked as read';
    } catch (e) {
      return e.toString();
    }
  }
}
