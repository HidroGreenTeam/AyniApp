import 'package:equatable/equatable.dart';

/// Profile Entity
/// Domain layer representation of a user profile in our application
class Profile extends Equatable {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => username;

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        phoneNumber,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
