class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromFirebaseMessage(Map<String, dynamic> message) {
    return NotificationModel(
      id: message['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message['notification']?['title'] ?? 'Notifikasi',
      body: message['notification']?['body'] ?? '',
      timestamp: DateTime.now(),
      data: message['data'],
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}