// models/user.dart
import 'package:json_annotation/json_annotation.dart';


@JsonEnum()
enum UserRole {
  @JsonValue('admin')
  admin,

  @JsonValue('viewer')
  viewer,
}

class User {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Safely parse from JSON with null fallback handling
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: _parseUserRole(json['role']),
      isActive: json['isActive'] == true, // fallback: false if null or invalid
      createdAt: DateTime.parse(json['createdAt'] ?? json['createdat']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updatedat']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role.name,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static UserRole _parseUserRole(dynamic value) {
    if (value is String) {
      return UserRole.values.firstWhere(
        (e) => e.name == value,
        orElse: () => UserRole.viewer,
      );
    }
    throw Exception('Invalid UserRole: $value');
  }
}
