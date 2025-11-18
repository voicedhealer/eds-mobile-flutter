class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? phone;
  final String? avatar;
  final bool isVerified;
  final String? favoriteCity;
  final UserRole role;
  final int karmaPoints;
  final List<dynamic>? gamificationBadges;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.name,
    this.phone,
    this.avatar,
    this.isVerified = false,
    this.favoriteCity,
    this.role = UserRole.user,
    this.karmaPoints = 0,
    this.gamificationBadges,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
      favoriteCity: json['favorite_city'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      karmaPoints: json['karma_points'] ?? 0,
      gamificationBadges: json['gamification_badges'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'is_verified': isVerified,
      'favorite_city': favoriteCity,
      'role': role.name,
      'karma_points': karmaPoints,
      'gamification_badges': gamificationBadges,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum UserRole {
  user,
  admin,
}

