import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'address.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> wishlistProductIds;
  final List<Address> addresses;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserPreferences? preferences;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.wishlistProductIds = const [],
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
    this.preferences,
  });

  // Create empty user
  static const empty = UserModel(
    id: '',
    email: '',
    name: '',
    wishlistProductIds: [],
    addresses: [],
  );

  // Check if user is empty
  bool get isEmpty => this == UserModel.empty;
  
  // Check if user is not empty
  bool get isNotEmpty => this != UserModel.empty;

  // Check if user is a guest (anonymous user)
  bool get isGuest => email.isEmpty || email == '';

  // Get primary address
  Address? get primaryAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  @override
  List<Object?> get props => [
    id, email, name, photoUrl, phoneNumber, dateOfBirth, gender,
    wishlistProductIds, addresses, createdAt, updatedAt, preferences
  ];
  
  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? wishlistProductIds,
    List<Address>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      wishlistProductIds: wishlistProductIds ?? this.wishlistProductIds,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'gender': gender,
      'wishlistProductIds': wishlistProductIds,
      'addresses': addresses.map((address) => address.toMap()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'preferences': preferences?.toMap(),
    };
  }
  
  // Create from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null
          ? _parseDateTime(map['dateOfBirth'])
          : null,
      gender: map['gender'],
      wishlistProductIds: List<String>.from(map['wishlistProductIds'] ?? []),
      addresses: (map['addresses'] as List<dynamic>?)
          ?.map((addressMap) => Address.fromMap(addressMap))
          .toList() ?? [],
      createdAt: map['createdAt'] != null
          ? _parseDateTime(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? _parseDateTime(map['updatedAt'])
          : null,
      preferences: map['preferences'] != null
          ? UserPreferences.fromMap(map['preferences'])
          : null,
    );
  }

  // Helper method to parse DateTime from either Timestamp or milliseconds
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}

class UserPreferences extends Equatable {
  final bool enableNotifications;
  final bool enableEmailMarketing;
  final String currency;
  final String language;
  final String theme; // 'light', 'dark', 'system'

  const UserPreferences({
    this.enableNotifications = true,
    this.enableEmailMarketing = false,
    this.currency = 'USD',
    this.language = 'en',
    this.theme = 'system',
  });

  @override
  List<Object?> get props => [
    enableNotifications, enableEmailMarketing, currency, language, theme
  ];

  UserPreferences copyWith({
    bool? enableNotifications,
    bool? enableEmailMarketing,
    String? currency,
    String? language,
    String? theme,
  }) {
    return UserPreferences(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableEmailMarketing: enableEmailMarketing ?? this.enableEmailMarketing,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableNotifications': enableNotifications,
      'enableEmailMarketing': enableEmailMarketing,
      'currency': currency,
      'language': language,
      'theme': theme,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      enableNotifications: map['enableNotifications'] ?? true,
      enableEmailMarketing: map['enableEmailMarketing'] ?? false,
      currency: map['currency'] ?? 'USD',
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'system',
    );
  }
}
