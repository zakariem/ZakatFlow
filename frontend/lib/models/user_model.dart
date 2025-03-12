class User {
  final String userId;
  final String fullname;
  final String token;

  User({required this.userId, required this.fullname, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'].toString(),
      fullname: json['fullName'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'fullname': fullname, 'token': token};
  }
}
