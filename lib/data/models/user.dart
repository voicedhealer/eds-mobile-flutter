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
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is DateTime) return date;
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    final now = DateTime.now();
    final createdAtValue = parseDate(json['created_at'] ?? json['createdAt']) ?? now;
    final updatedAtValue = parseDate(json['updated_at'] ?? json['updatedAt']) ?? now;

    return User(
      id: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'] ?? json['avatarUrl'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      favoriteCity: json['favorite_city'] ?? json['favoriteCity'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      karmaPoints: json['karma_points'] ?? json['karmaPoints'] ?? 0,
      gamificationBadges: json['gamification_badges'] ?? json['gamificationBadges'],
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
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

