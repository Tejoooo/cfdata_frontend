import 'package:flutter/material.dart';

class UserRating {
  final String? id;
  final String handle;
  final int rating;
  final DateTime? lastContestDate;


  UserRating({required this.handle, required this.rating,this.id,
this.lastContestDate});
  Map<String, dynamic> toJson() {
    return {
      'handle': handle,
      'rating': rating,
    };
  }
  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      id:json['id'],
      handle: json['handle'],
      rating: json['rating'],
       lastContestDate: null,
    );
  }
}

class UserRatingProvider extends ChangeNotifier {
  List<UserRating> _userRatings = [];

  List<UserRating> get userRatings => _userRatings;

  void addUserRating(UserRating userRating) {
    _userRatings.add(userRating);
    notifyListeners();
  }
}


class Rating{
  final int id;
  final String handle;
  final int rating;

  Rating({required this.id, required this.handle, required this.rating,
});

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'handle': handle,
      'rating': rating,
      
    };
  }
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      handle: json['handle'],
      rating: json['rating'],
    );
  }
}