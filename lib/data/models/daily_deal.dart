import 'dart:convert';
import 'establishment.dart';

class DailyDeal {
  final String id;
  final String establishmentId;
  final String title;
  final String description;
  final String? modality;
  final double? originalPrice;
  final double? discountedPrice;
  final String? imageUrl;
  final String? pdfUrl;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? heureDebut; // Format "HH:mm"
  final String? heureFin; // Format "HH:mm"
  final bool isActive;
  final String? promoUrl;
  final bool isRecurring;
  final String? recurrenceType; // 'weekly' | 'monthly'
  final List<int>? recurrenceDays; // [1,2,3,4,5] (1=lundi, 7=dimanche)
  final DateTime? recurrenceEndDate;
  final Establishment establishment;

  DailyDeal({
    required this.id,
    required this.establishmentId,
    required this.title,
    required this.description,
    this.modality,
    this.originalPrice,
    this.discountedPrice,
    this.imageUrl,
    this.pdfUrl,
    required this.dateDebut,
    required this.dateFin,
    this.heureDebut,
    this.heureFin,
    this.isActive = true,
    this.promoUrl,
    this.isRecurring = false,
    this.recurrenceType,
    this.recurrenceDays,
    this.recurrenceEndDate,
    required this.establishment,
  });

  factory DailyDeal.fromJson(Map<String, dynamic> json) {
    return DailyDeal(
      id: json['id'],
      establishmentId: json['establishment_id'] ?? json['establishmentId'],
      title: json['title'],
      description: json['description'],
      modality: json['modality'],
      originalPrice: json['original_price']?.toDouble() ?? json['originalPrice']?.toDouble(),
      discountedPrice: json['discounted_price']?.toDouble() ?? json['discountedPrice']?.toDouble(),
      imageUrl: json['image_url'] ?? json['imageUrl'],
      pdfUrl: json['pdf_url'] ?? json['pdfUrl'],
      dateDebut: DateTime.parse(json['date_debut'] ?? json['dateDebut']),
      dateFin: DateTime.parse(json['date_fin'] ?? json['dateFin']),
      heureDebut: json['heure_debut'] ?? json['heureDebut'],
      heureFin: json['heure_fin'] ?? json['heureFin'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      promoUrl: json['promo_url'] ?? json['promoUrl'],
      isRecurring: json['is_recurring'] ?? json['isRecurring'] ?? false,
      recurrenceType: json['recurrence_type'] ?? json['recurrenceType'],
      recurrenceDays: json['recurrence_days'] != null
          ? List<int>.from(json['recurrence_days'] is String
              ? jsonDecode(json['recurrence_days'])
              : json['recurrence_days'])
          : json['recurrenceDays'] != null
              ? (json['recurrenceDays'] is String
                  ? List<int>.from(jsonDecode(json['recurrenceDays']))
                  : List<int>.from(json['recurrenceDays']))
              : null,
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.parse(json['recurrence_end_date'])
          : json['recurrenceEndDate'] != null
              ? DateTime.parse(json['recurrenceEndDate'])
              : null,
      establishment: json['establishment'] != null && json['establishment'] is Map
          ? Establishment.fromJson(json['establishment'] as Map<String, dynamic>)
          : Establishment.fromJson({
              'id': json['establishment_id'] ?? json['establishmentId'] ?? '',
              'name': 'Établissement',
              'slug': '',
              'address': '',
              'owner_id': '',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            }),
    );
  }
}

