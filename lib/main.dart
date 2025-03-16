import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_quest/presentation/screens/auth/login_screen.dart';
import 'package:side_quest/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:side_quest/presentation/screens/widgets/bottom_nav.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with Splash Screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  // ✅ Check First-Time Use & Login Status
  Future<void> _checkAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isFirstTime = prefs.getBool('isFirstTime') ?? true; // Default: true
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;  // Default: false

    // Wait 3 seconds, then navigate accordingly
    Timer(Duration(seconds: 3), () {
      if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnboardingScreen()), // Show Onboarding first
        );
      } else if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNav()), // Go to Main App
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()), // Go to Login
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF019AD4), // Matches your design
      body: Center(
        child: Image.asset(
          'assets/images/logos.png', // Your splash image
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}