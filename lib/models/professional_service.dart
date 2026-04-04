import 'service_model.dart';

class ProfessionalService {
  final int id;
  final int professionalId;
  final int serviceId;
  final String? name;
  final double price;
  final int? durationMinutes;
  final bool isActive;
  final String? description;
  final ServiceModel? service;

  ProfessionalService({
    required this.id,
    required this.professionalId,
    required this.serviceId,
    this.name,
    required this.price,
    this.durationMinutes,
    required this.isActive,
    this.description,
    this.service,
  });

  factory ProfessionalService.fromJson(Map<String, dynamic> json) {
    return ProfessionalService(
      id: json['id'],
      professionalId: json['professional_id'] is String ? int.parse(json['professional_id']) : json['professional_id'],
      serviceId: json['service_id'] is String ? int.parse(json['service_id']) : json['service_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      durationMinutes: json['duration_minutes'] != null ? (json['duration_minutes'] is String ? int.parse(json['duration_minutes']) : json['duration_minutes']) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      description: json['description'],
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
    );
  }
}
