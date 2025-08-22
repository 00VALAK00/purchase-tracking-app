class User {
  final int id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

class UserProfile {
  final int id;
  final User user;
  final String role;
  final String? fidelityCardNumber;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.user,
    required this.role,
    this.fidelityCardNumber,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      user: User.fromJson(json['user']),
      role: json['role'],
      fidelityCardNumber: json['fidelity_card_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'role': role,
      'fidelity_card_number': fidelityCardNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
