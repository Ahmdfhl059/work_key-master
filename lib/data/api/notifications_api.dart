import 'package:dio/dio.dart';
import '../../utils/dio_methods.dart';

class NotificationsApi {
  Future<Response> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? isRead,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': perPage};
    if (isRead != null) query['is_read'] = isRead;
    return await RemoteApi.get('/notifications', queryParameters: query);
  }

  Future<Response> getUnreadCount() async {
    return await RemoteApi.get('/notifications/unread-count');
  }

  Future<Response> markAsRead(int notificationId) async {
    return await RemoteApi.patch('/notifications/$notificationId/read');
  }

  Future<Response> markAllAsRead() async {
    return await RemoteApi.patch('/notifications/read-all');
  }

  Future<Response> deleteNotification(int notificationId) async {
    return await RemoteApi.delete('/notifications/$notificationId');
  }
}
