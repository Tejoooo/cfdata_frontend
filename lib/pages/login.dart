// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cfdata/constants.dart';
import 'package:cfdata/pages/signup.dart';
import 'package:cfdata/pages/provider1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    const String apiUrl = '${api}login/';

    TokenProvider authProvider =
        Provider.of<TokenProvider>(context, listen: false);

    final String username = _usernameController.text.toString();
    final String password = _passwordController.text.toString();

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {"username": username, "password": password},
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['token'];
      authProvider.updateToken(accessToken);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', accessToken);
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      // Login failed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Login failed. Please check your username and password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), automaticallyImplyLeading: false),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            SizedBox(height: 16.0), // Add some spacing
            MouseRegion(
              cursor: SystemMouseCursors.click, // Set the cursor to clickable
              child: GestureDetector(
                onTap: () {
                  Navigator.popAndPushNamed(context, '/signup');
                },
                child: Text(
                  'Create New User',
                  style: TextStyle(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
