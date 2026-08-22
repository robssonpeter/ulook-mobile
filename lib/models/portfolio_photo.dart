class PortfolioPhoto {
  final int id;
  final int professionalId;
  final String photoUrl;
  final String? caption;
  final int sortOrder;

  PortfolioPhoto({
    required this.id,
    required this.professionalId,
    required this.photoUrl,
    this.caption,
    this.sortOrder = 0,
  });

  factory PortfolioPhoto.fromJson(Map<String, dynamic> json) {
    return PortfolioPhoto(
      id: json['id'],
      professionalId: json['professional_id'],
      photoUrl: json['photo_url'],
      caption: json['caption'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
