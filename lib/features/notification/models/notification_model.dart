class NotificationItemModel {
  final String id;
  final String title;
  final String message;

  NotificationItemModel({
    this.id = '',
    required this.title,
    required this.message,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id.isNotEmpty) '_id': id,
    'title': title,
    'message': message,
  };
}
