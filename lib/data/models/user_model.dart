class UserModel {
  String? message;
  final int id;
  String name;
  String email;
  String role;
  String status;
  String phone;
  String? avatarUrl;

  UserModel({
    this.message,
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
    this.avatarUrl,
  });

  factory UserModel.initial() => UserModel(
    id: -1,
    name: '',
    email: '',
    message: '',
    role: '',
    status: '',
    phone: '',
    avatarUrl: null,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'role': role,
      'status': status,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      avatarUrl: _nullableString(map['avatar_url'] ?? map['profile_image_url']),
    );
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }
}
