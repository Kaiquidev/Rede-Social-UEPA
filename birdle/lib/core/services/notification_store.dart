import 'package:flutter/foundation.dart';

import '../../models/app_notification_model.dart';

/// Gerencia as notificações in-app dos usuários.
class NotificationStore extends ChangeNotifier {
  final List<AppNotificationModel> _notifications = <AppNotificationModel>[];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<AppNotificationModel> notificationsForUser(String userId) {
    final list = _notifications
        .where((item) => item.userId == userId)
        .toList(growable: true);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int unreadCountForUser(String userId) {
    return _notifications
        .where((item) => item.userId == userId && !item.read)
        .length;
  }

  // ---------------------------------------------------------------------------
  // Adicionar
  // ---------------------------------------------------------------------------

  void add({
    required String userId,
    required String title,
    required String body,
  }) {
    _notifications.add(AppNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Marcar como lidas
  // ---------------------------------------------------------------------------

  void markAllAsRead(String userId) {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].read) {
        _notifications[i] = _notifications[i].copyWith(read: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
