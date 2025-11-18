class Professional {
  final String id;
  final String siret;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String companyName;
  final String legalStatus;
  final SubscriptionPlan subscriptionPlan;
  final bool siretVerified;
  final DateTime? siretVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Professional({
    required this.id,
    required this.siret,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.legalStatus,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.siretVerified = false,
    this.siretVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'],
      siret: json['siret'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      companyName: json['company_name'],
      legalStatus: json['legal_status'],
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (e) => e.name.toUpperCase() == json['subscription_plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      siretVerified: json['siret_verified'] ?? false,
      siretVerifiedAt: json['siret_verified_at'] != null
          ? DateTime.parse(json['siret_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

enum SubscriptionPlan {
  free,
  premium,
}

