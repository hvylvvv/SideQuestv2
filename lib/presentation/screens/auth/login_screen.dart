import 'package:flutter/material.dart';
import 'package:side_quest/presentation/screens/services/auth_service.dart';
import 'package:side_quest/presentation/screens/widgets/bottom_nav.dart';
import 'package:side_quest/presentation/screens/auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _keepMeSignedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthService.login(_emailController.text, _passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (response != null && response.containsKey("error")) {
      setState(() {
        _errorMessage = response["error"];
      });
    } else {
      // ✅ Navigate to home screen after successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Welcome Back To Our App", style: TextStyle(fontSize: 16, color: Colors.black54)),
                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton("Sign Up", false, context),
                    _buildTabButton("Login", true, context),
                  ],
                ),
                SizedBox(height: 30),

                _buildTextField(_emailController, "Email", "Please Enter Your Email"),
                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    TextButton(
                      onPressed: () {}, // Forgot password logic
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                _buildTextField(_passwordController, "Password", "Please Enter Your Password", isPassword: true),

                SizedBox(height: 30),

                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
                  SizedBox(height: 10),
                ],

                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF407BFF),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 130),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: _handleLogin,
                  child: Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),

                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _keepMeSignedIn,
                      onChanged: (value) {
                        setState(() {
                          _keepMeSignedIn = value!;
                        });
                      },
                    ),
                    Text("Keep me signed in", style: TextStyle(fontSize: 14)),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("or sign in with")),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),

                SizedBox(height: 15),

                GestureDetector(
                  onTap: () {}, // Add Google Sign-In logic
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google-icon.png', width: 24, height: 24),
                        SizedBox(width: 10),
                        Text("Continue With Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (text == "Sign Up") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black26),
        ),
      ),
    );
  }
}