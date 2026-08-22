/// An item in the "Followed" activity feed — an update, offer or style
/// posted by a professional the customer follows.
class ProfessionalPost {
  final int id;
  final String type; // update | offer | style
  final String title;
  final String? body;
  final String? imageUrl;
  final String? createdAt;
  final int professionalId;
  final String professionalName;
  final String? professionalPhoto;
  final String? location;

  ProfessionalPost({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.imageUrl,
    this.createdAt,
    required this.professionalId,
    required this.professionalName,
    this.professionalPhoto,
    this.location,
  });

  factory ProfessionalPost.fromJson(Map<String, dynamic> json) {
    return ProfessionalPost(
      id: json['id'],
      type: json['type'] ?? 'update',
      title: json['title'] ?? '',
      body: json['body'],
      imageUrl: json['image_url'],
      createdAt: json['created_at']?.toString(),
      professionalId: json['professional_id'] ?? 0,
      professionalName: json['professional_name'] ?? 'Professional',
      professionalPhoto: json['professional_photo'],
      location: json['location'],
    );
  }
}
