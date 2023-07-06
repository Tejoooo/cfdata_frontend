import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cfdata/pages/provider.dart';

class UserDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userRatingProvider = Provider.of<UserRatingProvider>(context);
    final userRatings = userRatingProvider.userRatings;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: ListView.builder(
        itemCount: userRatings.length,
        itemBuilder: (context, index) {
          final userRating = userRatings[index];
          return ListTile(
            title: Text(userRating.handle),
            subtitle: Text('Rating: ${userRating.rating}'),
          );
        },
      ),
    );
  }
}
