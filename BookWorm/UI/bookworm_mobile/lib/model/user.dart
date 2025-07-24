import 'package:json_annotation/json_annotation.dart';
import 'role.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final int age;
  final int countryId;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final DateTime? lastLoginAt;
  final String? photoUrl;
  final List<Role> roles;

  User({
    this.id = 0,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.username = '',
    this.age = 0,
    this.countryId = 0,
    this.phoneNumber = '',
    this.isActive = true,
    DateTime? createdAt,
    this.modifiedAt,
    this.lastLoginAt,
    this.photoUrl,
    this.roles = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}