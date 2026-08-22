class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        type: json['type'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'])
            : null,
        isRead: json['is_read'] ?? false,
        readAt: json['read_at'],
        createdAt: json['created_at'] ?? '',
      );
}
