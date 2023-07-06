import 'package:cfdata/pages/login.dart';
import 'package:cfdata/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cfdata/pages/ratingpage.dart';
import 'package:cfdata/pages/provider.dart';
import 'package:cfdata/pages/provider1.dart';
import 'package:cfdata/pages/user_details.dart';
import 'package:cfdata/pages/searchpage.dart';
import 'package:cfdata/pages/home.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TokenProvider()), // Add the TokenProvider here
        ChangeNotifierProvider(create: (context) => UserRatingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Codeforces Rating App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/rating': (context) => RatingScreen(),
          '/userDetails': (context) => UserDetailsPage(),
          '/login': (context) => Login(),
          '/signup': (context) => Signup(),
        },
        onGenerateRoute: (settings) {
        // Handle named routes with arguments
        if (settings.name == '/home') {
          final String? username = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => Home(username: username),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
          // Handle unknown routes here
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Not Found')),
              body: Center(child: Text('Page not found')),
            ),
          );
        },
      ),
    );
  }
}
