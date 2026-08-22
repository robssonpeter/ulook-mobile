import 'service_model.dart';
import 'professional_service.dart';
import 'working_hours.dart';

class Professional {
  final int id;
  final String name;
  final String bio;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final String priceRange;
  final int? yearsExperience;
  final String category;
  final double averageRating;
  final int reviewsCount;
  final String? profilePhotoUrl;
  final List<ServiceModel>? services;
  final List<ProfessionalService>? professionalServices;
  final bool isVerified;
  final String? verificationStatus;
  final bool isFollowing;
  final int followersCount;
  final List<WorkingHours>? workingHours;

  Professional({
    required this.id,
    required this.name,
    required this.bio,
    required this.location,
    this.latitude,
    this.longitude,
    this.distance,
    required this.priceRange,
    this.yearsExperience,
    required this.category,
    this.averageRating = 0.0,
    this.reviewsCount = 0,
    this.profilePhotoUrl,
    this.services,
    this.professionalServices,
    this.isVerified = false,
    this.verificationStatus,
    this.isFollowing = false,
    this.followersCount = 0,
    this.workingHours,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'],
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
      priceRange: json['price_range'] ?? '',
      yearsExperience: json['years_experience'] != null ? int.tryParse(json['years_experience'].toString()) : null,
      category: json['category'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      profilePhotoUrl: json['profile_photo_url'],
      services: json['services'] != null
          ? (json['services'] as List).map((i) => ServiceModel.fromJson(i)).toList()
          : null,
      professionalServices: json['professional_services'] != null
          ? (json['professional_services'] as List).map((i) => ProfessionalService.fromJson(i)).toList()
          : null,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      verificationStatus: json['verification_status'],
      isFollowing: json['is_following'] == true || json['is_following'] == 1,
      followersCount: json['followers_count'] ?? 0,
      workingHours: json['working_hours'] != null
          ? (json['working_hours'] as List).map((i) => WorkingHours.fromJson(i)).toList()
          : null,
    );
  }
}
