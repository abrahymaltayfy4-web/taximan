// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  // Convert Firestore Document to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      uid: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
    };
  }

  // CopyWith for immutability and state updates
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, phone, createdAt];
}