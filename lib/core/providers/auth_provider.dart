import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? token;
  String? role;
  String? userId;
  String? username;

  bool get isLoggedIn => token != null;

 Future<void> login(String usernameInput, String passwordInput) async {
  try {
    final result = await _authService.login(
      username: usernameInput,
      password: passwordInput,
    );

    // ✅ Log the full result for debugging
    print("🔥 Login result: $result");

    token = result['token'];
    userId = result['user']['id'];
    username = result['user']['name'];
    role = result['user']['role'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token!);
    await prefs.setString('role', role!);

    notifyListeners();
  } catch (e) {
    print("❌ Login failed: $e");
    rethrow; // rethrow so UI can show the error
  }
}

  Future<void> logout() async {
    token = null;
    role = null;
    userId = null;
    username = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');

    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    role = prefs.getString('role');
    notifyListeners();
  }
}
