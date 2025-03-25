class User {
  final String id;
  final String fullName;
  final String email;
  final String profileImageUrl;
  final String role;
  final String token;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
    required this.profileImageUrl,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'token': token,
    };
  }
}
