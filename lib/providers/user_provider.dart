import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _username;
  bool _isAuthenticated = false;

  int? get userId => _userId;
  String? get username => _username;
  bool get isAuthenticated => _isAuthenticated;

  void setUser(int id, String name) {
    _userId = id;
    _username = name;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _username = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
