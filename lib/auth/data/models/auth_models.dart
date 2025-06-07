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
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // El backend puede devolver el id y datos del usuario en la raíz o en un objeto 'user'
      final userJson = json['user'] ?? json;
      return AuthResponse(
        token: json['token'] ?? '',
        user: UserModel.fromJson(userJson),
      );
    } catch (e) {
      return AuthResponse(
        token: json['token'] ?? '',
        user: UserModel(id: '0', username: '', email: '', phoneNumber: '', imageUrl: null),
      );
    }
  }
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '0',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
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
