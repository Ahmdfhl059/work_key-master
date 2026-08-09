class NotificationModel {
  String? message;
  final int id;
  String type;
  String data;
  String readAt;
  String createdAt;

  NotificationModel({
    this.message,
    required this.id,
    required this.type,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.initial() => NotificationModel(
    id: -1,
    message: '',
    type: '',
    data: '',
    readAt: '',
    createdAt: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'type': type,
      'data': data,
      'read_at': readAt,
      'created_at': createdAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? -1,
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      data: map['data']?.toString() ?? '',
      readAt: map['read_at'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }
}
