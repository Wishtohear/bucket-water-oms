import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _apiClient.get('/notifications/unread');
      if (response.success && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<NotificationModel>> getAllNotifications({
    String? type,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final Map<String, String> params = {
        'page': page.toString(),
        'size': size.toString(),
      };
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }

      final response =
          await _apiClient.get('/notifications', queryParams: params);
      if (response.success && response.data != null) {
        final List<dynamic> list = response.data is List ? response.data : [];
        return list.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      if (response.success && response.data != null) {
        final countData = NotificationUnreadCount.fromJson(response.data);
        return countData.count;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient
          .post('/notifications/$notificationId/read', body: {});
      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response =
          await _apiClient.post('/notifications/read-all', body: {});
      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response =
          await _apiClient.delete('/notifications/$notificationId');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    return getAllNotifications(type: type);
  }
}
