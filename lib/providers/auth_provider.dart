import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String _token = '';

  User? get user => _user;
  String get token => _token;
  bool get isAuthenticated => _user != null && _token.isNotEmpty;

  void setUser(User user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = '';
    notifyListeners();
  }

  String get userRole => _user?.role ?? '';
}
