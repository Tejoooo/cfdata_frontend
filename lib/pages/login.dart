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
    final String apiUrl = '$api/login/';
    TokenProvider authProvider = Provider.of<TokenProvider>(context, listen: false);

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;
    print(username);

    final Map<String, dynamic> loginData = {
      'username': username,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    print(apiUrl);
    print("adf");
    print(response.statusCode);
      print("adf");
    print(loginData[username]);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(response.body);
      final accessToken = responseData['access_token'];
      authProvider.updateToken(accessToken);
      final prefs = await SharedPreferences.getInstance();
    prefs.setString('auth_token', accessToken);
      print(loginData[username]);
      final String uname = username;
  Navigator.pushReplacementNamed(
    context,
    '/home',
    arguments: uname,
  );
    } else {
      // Login failed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Login failed. Please check your username and password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
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
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false
      ),
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
