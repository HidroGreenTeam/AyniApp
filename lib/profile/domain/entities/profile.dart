import 'package:equatable/equatable.dart';

/// Profile Entity
/// Domain layer representation of a user profile in our application
class Profile extends Equatable {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? location;
  final List<String>? interests;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.bio,
    this.profilePicture,
    this.dateOfBirth,
    this.location,
    this.interests,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return firstName ?? lastName ?? 'Usuario';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        email,
        phoneNumber,
        bio,
        profilePicture,
        dateOfBirth,
        location,
        interests,
        isVerified,
        createdAt,
        updatedAt,
      ];
}
