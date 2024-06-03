class Review {
  double rating;
  String review;
  String revieweeId;

  Review({
    required this.rating,
    required this.review,
    required this.revieweeId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: json['rating'] ?? 0.0,
      review: json['review'] ?? '',
      revieweeId: json['revieweeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'review': review,
      'revieweeId': revieweeId,
    };
  }
}
