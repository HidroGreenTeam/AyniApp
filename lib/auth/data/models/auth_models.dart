import '../../domain/entities/user.dart';

class AuthRequest {
  final String email;
  final String password;

  AuthRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.user,
  });  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle case where id might be an int or could be 0 from the API
      String userId = json['id'] != null ? json['id'].toString() : '0';
      
      return AuthResponse(
        token: json['token'] ?? '',
        user: UserModel.fromJson({
          'id': userId, 
          'email': json['email'] ?? '',
          'name': null, // API doesn't provide name
          'profilePicture': null, // API doesn't provide profilePicture
        }),
      );
    } catch (e) {
      // Return a default response in case of parsing error
      return AuthResponse(
        token: json['token'] ?? '',
        user: UserModel.fromJson({
          'id': '0',
          'email': json['email'] ?? '',
          'name': null,
          'profilePicture': null,
        }),
      );
    }
  }
}

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.profilePicture,
  });  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? json['id'].toString() : '0',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
    };
  }
}

class SignUpRequest {
  final String fullName;
  final String email;
  final String password;
  final List<String> roles;

  SignUpRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'roles': roles,
    };
  }
}
