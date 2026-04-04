import 'service_model.dart';

class Professional {
  final int id;
  final String name;
  final String bio;
  final String location;
  final String priceRange;
  final String category;
  final List<ServiceModel>? services;

  Professional({
    required this.id,
    required this.name,
    required this.bio,
    required this.location,
    required this.priceRange,
    required this.category,
    this.services,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'],
      name: json['name'],
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      priceRange: json['price_range'] ?? '',
      category: json['category'] ?? '',
      services: json['services'] != null
          ? (json['services'] as List)
              .map((i) => ServiceModel.fromJson(i))
              .toList()
          : null,
    );
  }
}
