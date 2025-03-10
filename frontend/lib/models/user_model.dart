class User {
  final String userId;
  final String fullname;
  final String token;

  User({required this.userId, required this.fullname, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'].toString(),
      fullname: json['fullname'],
      token: json['token'],
    );
  }
}
