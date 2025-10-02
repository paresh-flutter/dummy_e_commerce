import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  // Create empty user
  static const empty = UserModel(id: '', email: '', name: '');

  // Check if user is empty
  bool get isEmpty => this == UserModel.empty;
  
  // Check if user is not empty
  bool get isNotEmpty => this != UserModel.empty;

  @override
  List<Object?> get props => [id, email, name, photoUrl];
  
  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
  
  // Create from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }
}
