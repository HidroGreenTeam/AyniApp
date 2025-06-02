import 'package:equatable/equatable.dart';

/// User Entity
/// Domain layer representation of a user in our application
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? profilePicture;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [id, email, name, profilePicture];
}
