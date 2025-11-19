import 'establishment.dart';

class UserComment {
  final String id;
  final String userId;
  final String establishmentId;
  final String content;
  final int? rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Establishment? establishment;

  UserComment({
    required this.id,
    required this.userId,
    required this.establishmentId,
    required this.content,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.establishment,
  });

  factory UserComment.fromJson(Map<String, dynamic> json) {
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

    Establishment? establishment;
    if (json['establishment'] != null) {
      try {
        establishment = Establishment.fromJson(json['establishment']);
      } catch (e) {
        print('Erreur parsing establishment dans comment: $e');
      }
    }

    return UserComment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      establishmentId: json['establishment_id'] ?? json['establishmentId'] ?? '',
      content: json['content'] ?? '',
      rating: json['rating'],
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
      establishment: establishment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'establishment_id': establishmentId,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

