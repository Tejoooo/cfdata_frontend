import 'package:flutter/material.dart';
import 'package:cfdata/pages/ratingpage.dart';

class Home extends StatelessWidget {
  final String? username; // Change the type to String?

  Home({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/cfimage.png', // Replace with the path to your image asset
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 20),
            Text('Welcome ${username ?? ''}!'),
            ElevatedButton(
              onPressed: () {
                // Navigate to the rating page when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RatingScreen()),
                );
              },
              child: Text('Know your Codeforces rating'),
            ),
          ],
        ),
      ),
    );
  }
}
