class Agent {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final String? profileImageUrl;
  final String? cloudinaryPublicId;
  final double? totalDonation;

  Agent({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    this.profileImageUrl,
    this.cloudinaryPublicId,
    this.totalDonation,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      cloudinaryPublicId: json['cloudinaryPublicId'],
      totalDonation: json['totalDonation']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'cloudinaryPublicId': cloudinaryPublicId,
      'totalDonation': totalDonation,
    };
  }
}
