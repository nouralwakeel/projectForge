class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String? body;
  DateTime? readAt;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: (json['type'] ?? 'general').toString(),
      title: (json['title'] ?? '').toString(),
      body: json['body']?.toString(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
