class Review {
  final int id;
  final int bookingId;
  final int rating;
  final String? comment;
  final String? reviewerName;
  final String? createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.reviewerName,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      bookingId: json['booking_id'],
      rating: json['rating'],
      comment: json['comment'],
      reviewerName: json['reviewer_name'],
      createdAt: json['created_at'],
    );
  }
}
