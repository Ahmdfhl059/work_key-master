import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class NotificationsApi {
  Future<Response> getNotifications() async {
    return await RemoteApi.get('/notifications');
  }

  Future<Response> getUnreadCount() async {
    return await RemoteApi.get('/notifications/unread-count');
  }

  Future<Response> markAsRead(int notificationId) async {
    return await RemoteApi.post('/notifications/$notificationId/read');
  }

  Future<Response> markAllAsRead() async {
    return await RemoteApi.post('/notifications/read-all');
  }
}
