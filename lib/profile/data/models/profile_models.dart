import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.userId,
    super.firstName,
    super.lastName,
    super.email,
    super.phoneNumber,
    super.bio,
    super.profilePicture,
    super.dateOfBirth,
    super.location,
    super.interests,
    super.isVerified = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      bio: json['bio']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      location: json['location']?.toString(),
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : null,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'location': location,
      'interests': interests,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? bio,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? location,
    List<String>? interests,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Request models for API calls
class CreateProfileRequest {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? location;
  final List<String>? interests;

  CreateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.bio,
    this.dateOfBirth,
    this.location,
    this.interests,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'location': location,
      'interests': interests,
    };
  }
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? location;
  final List<String>? interests;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.bio,
    this.dateOfBirth,
    this.location,
    this.interests,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (bio != null) data['bio'] = bio;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (location != null) data['location'] = location;
    if (interests != null) data['interests'] = interests;
    
    return data;
  }
}
