import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = "http://10.0.2.2:3001/api"; // Use this for local API

  // ✅ Login API Request
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Extract user details
        String token = data['token'];
        String username = data['username'];
        int experience = data['experience'];
        List<dynamic> history = data['history'];

        // ✅ Store user details locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setInt('experience', experience);
        await prefs.setString('history', jsonEncode(history));

        return {"success": true, "token": token};
      } else {
        return {"error": jsonDecode(response.body)["message"] ?? "Login failed"};
      }
    } catch (e) {
      return {"error": "Error connecting to the server"};
    }
  }

  // ✅ Signup API Request
  static Future<Map<String, dynamic>?> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // ✅ Extract user details
        String token = data['token'];
        int experience = data['experience'];
        List<dynamic> history = data['history'];

        // ✅ Store user details locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setInt('experience', experience);
        await prefs.setString('history', jsonEncode(history));

        return {"success": true, "token": token};
      } else {
        return {"error": jsonDecode(response.body)["message"] ?? "Signup failed"};
      }
    } catch (e) {
      return {"error": "Error connecting to the server"};
    }
  }

  // ✅ Logout (Clear stored data)
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('experience');
    await prefs.remove('history');
  }

  // ✅ Check if User is Logged In
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // ✅ Get JWT Token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Get Stored User Profile Data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isLoggedIn') ?? false) {
      return {
        "username": prefs.getString('username'),
        "experience": prefs.getInt('experience'),
        "history": jsonDecode(prefs.getString('history') ?? "[]"),
      };
    }
    return null;
  }
}