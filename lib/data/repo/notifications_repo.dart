import 'package:dio/dio.dart';
import '../api/notifications_api.dart';
import '../models/notification_model.dart';

class NotificationsRepo {
  final NotificationsApi _notificationsApi = NotificationsApi();

  Future<List<NotificationModel>> getNotifications() async {
    Response response = await _notificationsApi.getNotifications();
    final root = Map<String, dynamic>.from(response.data as Map);
    if (root['success'] != true)
      throw StateError(
        root['message']?.toString() ?? 'Could not load notifications',
      );
    final data = root['data'];
    final list = data is List
        ? data
        : data is Map && data['data'] is List
        ? data['data'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> getUnreadCount() async {
    try {
      Response response = await _notificationsApi.getUnreadCount();
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return int.tryParse('${data['unread_count'] ?? data['count'] ?? 0}') ??
            0;
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

  Future<String> markAllAsRead() async {
    final response = await _notificationsApi.markAllAsRead();
    return response.data['message']?.toString() ??
        'All notifications marked as read';
  }

  Future<void> deleteNotification(int id) async {
    final response = await _notificationsApi.deleteNotification(id);
    final data = response.data;
    if (data is Map && data['success'] == false) {
      throw StateError(
        data['message']?.toString() ?? 'Could not delete notification',
      );
    }
  }
}
