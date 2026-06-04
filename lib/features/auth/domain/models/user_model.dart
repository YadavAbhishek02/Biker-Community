import 'package:equatable/equatable.dart';

enum UserRole { admin, user }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? bikeModel;
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.bikeModel,
    this.profileImageUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? bikeModel,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      bikeModel: bikeModel ?? this.bikeModel,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'bikeModel': bikeModel,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      bikeModel: map['bikeModel'],
      profileImageUrl: map['profileImageUrl'],
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, bikeModel, profileImageUrl];
}
