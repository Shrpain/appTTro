class User {
  final int id;
  final String fullname;
  final String email;
  final String phone;
  final String role;
  final double reputationScore;
  final String avatar;
  final String? token;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
    this.reputationScore = 0.0,
    this.avatar = 'default_avatar.jpg',
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      reputationScore: (json['reputation_score'] as num?)?.toDouble() ?? 0.0,
      avatar: json['avatar'] as String? ?? 'default_avatar.jpg',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'role': role,
      'reputation_score': reputationScore,
      'avatar': avatar,
      'token': token,
    };
  }
}
