import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void updateToken(String token) {
    _accessToken = token;
    notifyListeners();
  }
  void clearAccessToken() {
    _accessToken = null;
    notifyListeners();
  }
}