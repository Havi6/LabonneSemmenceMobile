import 'package:la_bonne_semence_mobile/models/entities.dart';

class AppUser {
  final String? id;
  final String name;
  final String email;
  final String? role;
  final DateTime? createdAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    this.role,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: readString(json, ['id', '_id']),
    name: readString(json, ['name', 'nom', 'username', 'display_name']) ?? '',
    email: readString(json, ['email']) ?? '',
    role: readString(json, ['role', 'type']),
    createdAt: DateTime.tryParse(readString(json, ['createdAt', 'created_at']) ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'username': name,
    'email': email,
    if (role != null) 'role': role,
  };
}
