class ServiceRequestResponse {
  final int id;
  final int serviceRequestId;
  final int professionalId;
  final int? professionalUserId;
  final String? professionalName;
  final String? professionalLocation;
  final double professionalRating;
  final int professionalReviewsCount;
  final String? professionalPhotoUrl;
  final double priceOffered;
  final String? message;
  final String status; // pending | accepted | rejected
  final String? createdAt;

  const ServiceRequestResponse({
    required this.id,
    required this.serviceRequestId,
    required this.professionalId,
    this.professionalUserId,
    this.professionalName,
    this.professionalLocation,
    this.professionalRating = 0,
    this.professionalReviewsCount = 0,
    this.professionalPhotoUrl,
    required this.priceOffered,
    this.message,
    required this.status,
    this.createdAt,
  });

  factory ServiceRequestResponse.fromJson(Map<String, dynamic> json) {
    final pro = json['professional'] as Map<String, dynamic>?;
    return ServiceRequestResponse(
      id: json['id'],
      serviceRequestId: json['service_request_id'],
      professionalId: json['professional_id'],
      professionalUserId: pro?['user_id'] != null
          ? (pro!['user_id'] as num).toInt()
          : null,
      professionalName: pro?['name'],
      professionalLocation: pro?['location'],
      professionalRating: double.tryParse((pro?['average_rating'] ?? 0).toString()) ?? 0,
      professionalReviewsCount: pro?['reviews_count'] ?? 0,
      professionalPhotoUrl: pro?['profile_photo_url'],
      priceOffered: double.parse((json['price_offered'] ?? 0).toString()),
      message: json['message'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
    );
  }
}

class ServiceRequest {
  final int id;
  final int customerId;
  final int? serviceId;
  final String? serviceName;
  final String? description;
  final String customerAddress;
  final double customerLatitude;
  final double customerLongitude;
  final String requestedDate;
  final String requestedTime;
  final double radiusKm;
  final String status; // open | matched | cancelled
  final int? matchedProfessionalId;
  final int? matchedBookingId;
  final int responsesCount;
  final List<ServiceRequestResponse> responses;
  final String? createdAt;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.serviceId,
    this.serviceName,
    this.description,
    required this.customerAddress,
    required this.customerLatitude,
    required this.customerLongitude,
    required this.requestedDate,
    required this.requestedTime,
    this.radiusKm = 25,
    required this.status,
    this.matchedProfessionalId,
    this.matchedBookingId,
    this.responsesCount = 0,
    this.responses = const [],
    this.createdAt,
  });

  bool get isOpen => status == 'open';
  bool get isMatched => status == 'matched';

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      description: json['description'],
      customerAddress: json['customer_address'] ?? '',
      customerLatitude: double.tryParse((json['customer_latitude'] ?? 0).toString()) ?? 0,
      customerLongitude: double.tryParse((json['customer_longitude'] ?? 0).toString()) ?? 0,
      requestedDate: json['requested_date'] ?? '',
      requestedTime: json['requested_time'] ?? '',
      radiusKm: double.tryParse((json['radius_km'] ?? 25).toString()) ?? 25,
      status: json['status'] ?? 'open',
      matchedProfessionalId: json['matched_professional_id'],
      matchedBookingId: json['matched_booking_id'],
      responsesCount: json['responses_count'] ?? 0,
      responses: (json['responses'] as List? ?? [])
          .map((r) => ServiceRequestResponse.fromJson(r))
          .toList(),
      createdAt: json['created_at'],
    );
  }
}
