// models/user_model.dart
import 'dart:convert';

import 'package:esx/features/profile/models/address_model.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final List<Address> address;
  final String role;
  final bool isProfileComplete;
  final bool isNewUser;
  final List<String> order;
  final List<Bid> bids;
  final AdminDetails adminDetails;
  final String accessToken;
  final String refreshToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.isProfileComplete,
    required this.isNewUser,
    required this.order,
    required this.bids,
    required this.adminDetails,
    required this.accessToken,
    required this.refreshToken,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get displayName => fullName.isNotEmpty ? fullName : 'Guest User';

  bool get hasCompleteName => firstName.isNotEmpty && lastName.isNotEmpty;

  String get formattedPhoneNumber {
    // Format phone number from 919116492511 to +91 91164 92511
    if (phoneNumber.length >= 12) {
      return '+${phoneNumber.substring(0, 2)} ${phoneNumber.substring(2, 7)} ${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['*id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      address: (json['address'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Address.fromJson(e))
          .toList(),
      role: json['role'] ?? 'user',
      isProfileComplete: json['isProfileComplete'] ?? false,
      isNewUser: json['isNewUser'] ?? true,
      order: List<String>.from(json['order'] ?? []),
      bids: (json['bids'] as List<dynamic>? ?? [])
          .map((e) => Bid.fromJson(e))
          .toList(),
      adminDetails: json['adminDetails'] is Map<String, dynamic>
          ? AdminDetails.fromJson(
              Map<String, dynamic>.from(json['adminDetails']))
          : AdminDetails(documents: []),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      version: json['__v'] ?? 0,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Use *id to match your API response format
      '*id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'isProfileComplete': isProfileComplete,
      'isNewUser': isNewUser,
      'order': order,
      'bids': bids.map((b) => b.toJson()).toList(),
      'adminDetails': adminDetails.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    List<Address>? address,
    String? role,
    bool? isProfileComplete,
    bool? isNewUser,
    List<String>? order,
    List<Bid>? bids,
    AdminDetails? adminDetails,
    String? accessToken,
    String? refreshToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isNewUser: isNewUser ?? this.isNewUser,
      order: order ?? this.order,
      bids: bids ?? this.bids,
      adminDetails: adminDetails ?? this.adminDetails,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, fullName: $fullName, role: $role}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AdminDetails {
  final List<String> documents;

  AdminDetails({
    required this.documents,
  });

  factory AdminDetails.fromJson(Map<String, dynamic> json) {
    return AdminDetails(
      documents: List<String>.from(json['documents'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documents': documents,
    };
  }

  AdminDetails copyWith({
    List<String>? documents,
  }) {
    return AdminDetails(
      documents: documents ?? this.documents,
    );
  }
}

class Bid {
  final String productId;
  final int amount;
  final String id;

  Bid({
    required this.productId,
    required this.amount,
    required this.id,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      productId: json['productId'] ?? '',
      amount: json['amount'] ?? 0,
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'amount': amount,
      '_id': id,
    };
  }

  @override
  String toString() => 'Bid(productId: $productId, amount: $amount, id: $id)';
}
