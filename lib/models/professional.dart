import 'service_model.dart';
import 'professional_service.dart';

class Professional {
  final int id;
  final String name;
  final String bio;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final String priceRange;
  final String category;
  final List<ServiceModel>? services;
  final List<ProfessionalService>? professionalServices;

  Professional({
    required this.id,
    required this.name,
    required this.bio,
    required this.location,
    this.latitude,
    this.longitude,
    this.distance,
    required this.priceRange,
    required this.category,
    this.services,
    this.professionalServices,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'],
      name: json['name'],
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
      priceRange: json['price_range'] ?? '',
      category: json['category'] ?? '',
      services: json['services'] != null
          ? (json['services'] as List)
              .map((i) => ServiceModel.fromJson(i))
              .toList()
          : null,
      professionalServices: json['professional_services'] != null
          ? (json['professional_services'] as List)
              .map((i) => ProfessionalService.fromJson(i))
              .toList()
          : null,
    );
  }
}
