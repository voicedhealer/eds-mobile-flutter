class Event {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String establishmentId;
  final DateTime startDate;
  final DateTime? endDate;
  final double? price;
  final String? priceUnit;
  final int? maxCapacity;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.establishmentId,
    required this.startDate,
    this.endDate,
    this.price,
    this.priceUnit,
    this.maxCapacity,
    this.isRecurring = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      establishmentId: json['establishment_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      price: json['price']?.toDouble(),
      priceUnit: json['price_unit'],
      maxCapacity: json['max_capacity'],
      isRecurring: json['is_recurring'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

