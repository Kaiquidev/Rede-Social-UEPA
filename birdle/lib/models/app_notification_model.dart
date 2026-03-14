class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  AppNotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
