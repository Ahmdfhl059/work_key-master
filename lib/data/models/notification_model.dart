class NotificationModel {
  String? message;
  final int id;
  String type;
  Map<String, dynamic> data;
  String? readAt;
  String createdAt;

  NotificationModel({
    this.message,
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.initial() => NotificationModel(
    id: -1,
    message: '',
    type: '',
    data: const {},
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
      id: int.tryParse('${map['id'] ?? ''}') ?? -1,
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      data: map['data'] is Map
          ? Map<String, dynamic>.from(map['data'])
          : const {},
      readAt: map['read_at']?.toString(),
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  bool get isRead => readAt != null && readAt!.isNotEmpty;
}
