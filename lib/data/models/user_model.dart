import '../../utils/media_url.dart';

class UserModel {
  String? message;
  final int id;
  String name;
  String email;
  String role;
  String status;
  String phone;
  String? avatarUrl;
  final bool emailVerified;

  UserModel({
    this.message,
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
    this.avatarUrl,
    this.emailVerified = true,
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
    emailVerified: false,
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
      'email_verified': emailVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      role: _displayValue(map['role']),
      status: _displayValue(map['status']),
      phone: map['phone']?.toString() ?? '',
      avatarUrl: resolveMediaUrl(
        map['avatar_url'] ??
            map['profile_image_url'] ??
            map['profile_photo_url'] ??
            map['profile_picture_url'] ??
            map['avatar'] ??
            map['profile_image'] ??
            map['photo_url'] ??
            map['image_url'] ??
            map['image'],
      ),
      // Missing verification fields mean the backend does not expose this
      // capability. Explicit false/null email_verified_at must never be
      // treated as a verified login.
      emailVerified: _emailVerified(map),
    );
  }

  static bool _emailVerified(Map<String, dynamic> map) {
    if (map.containsKey('email_verified_at')) {
      return _nullableString(map['email_verified_at']) != null;
    }
    final value = map['is_email_verified'] ?? map['email_verified'];
    if (value == null) return true;
    return value == true || value == 1 || value.toString() == '1';
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }

  static String _displayValue(dynamic value) {
    if (value is Map) {
      return '${value['value'] ?? value['label'] ?? value['key'] ?? ''}';
    }
    return '${value ?? ''}';
  }
}
