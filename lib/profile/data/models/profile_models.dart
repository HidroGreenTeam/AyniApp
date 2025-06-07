
class ProfileModel {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '0',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Request models for API calls
class CreateProfileRequest {
  final String username;
  final String email;
  final String phoneNumber;
  final String password;

  CreateProfileRequest({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}

class UpdateProfileRequest {
  final String? username;
  final String? phoneNumber;

  UpdateProfileRequest({
    this.username,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (username != null) data['username'] = username;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    return data;
  }
}
