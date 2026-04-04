import 'professional.dart';
import 'service_model.dart';
import 'professional_service.dart';

class Booking {
  final int id;
  final int userId;
  final int professionalId;
  final int? serviceId;
  final int? professionalServiceId;
  final String bookingDate;
  final String bookingTime;
  final double totalPrice;
  final String status;
  final Professional? professional;
  final ServiceModel? service;
  final ProfessionalService? professionalService;

  Booking({
    required this.id,
    required this.userId,
    required this.professionalId,
    this.serviceId,
    this.professionalServiceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalPrice,
    required this.status,
    this.professional,
    this.service,
    this.professionalService,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'],
      professionalId: json['professional_id'] is String ? int.parse(json['professional_id']) : json['professional_id'],
      serviceId: json['service_id'] != null ? (json['service_id'] is String ? int.parse(json['service_id']) : json['service_id']) : null,
      professionalServiceId: json['professional_service_id'] != null ? (json['professional_service_id'] is String ? int.parse(json['professional_service_id']) : json['professional_service_id']) : null,
      bookingDate: json['booking_date'],
      bookingTime: json['booking_time'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      professional: json['professional'] != null ? Professional.fromJson(json['professional']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      professionalService: json['professional_service'] != null ? ProfessionalService.fromJson(json['professional_service']) : null,
    );
  }
}
