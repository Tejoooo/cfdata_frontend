class UserRating {
  final String handle;
  final int rating;

  UserRating({required this.handle, required this.rating});
  Map<String, dynamic> toJson() {
    return {
      'handle': handle,
      'rating': rating,
    };
  }
}
