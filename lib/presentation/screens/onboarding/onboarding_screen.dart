import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_quest/presentation/screens/auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  Future<void> _completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    // Navigate to Login after onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/background-image.jpeg',
            fit: BoxFit.cover, // Cover the full screen
          ),

          // Content Overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 80), // Top spacing

              // Logo at the top
              Image.asset(
                'assets/logos/new-logo.png',
                width: 350, // Adjust size as needed
              ),

              Spacer(), // Push content downward

              // Get Started Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF407BFF), // Button color
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  onPressed: () => _completeOnboarding(context),
                  child: Text(
                    "GET STARTED",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ✅ Button text color changed to white
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Sign In Link
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // ✅ White text for sign-in link
                    decoration: TextDecoration.none, // ✅ Underline for link effect
                  ),
                ),
              ),

              SizedBox(height: 50), // Space before bottom edge
            ],
          ),
        ],
      ),
    );
  }
}