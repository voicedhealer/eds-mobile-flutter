import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/data/models/user.dart';

void main() {
  group('User', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'name': 'John Doe',
        'phone': '+33123456789',
        'avatar': 'https://example.com/avatar.jpg',
        'is_verified': true,
        'favorite_city': 'Paris',
        'role': 'user',
        'karma_points': 100,
        'gamification_badges': ['early_adopter'],
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.name, 'John Doe');
      expect(user.isVerified, true);
      expect(user.favoriteCity, 'Paris');
      expect(user.role, UserRole.user);
      expect(user.karmaPoints, 100);
    });

    test('toJson should serialize correctly', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isVerified: true,
        favoriteCity: 'Paris',
        role: UserRole.user,
        karmaPoints: 100,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['is_verified'], true);
      expect(json['favorite_city'], 'Paris');
      expect(json['role'], 'user');
      expect(json['karma_points'], 100);
    });
  });
}

