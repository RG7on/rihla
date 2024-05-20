import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter your email address', Colors.red);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Showing a dialog instead of navigating directly can solve context issues
      _showResetDialog();
    } catch (e) {
      _showSnackBar('Failed to send reset link: $e', Colors.red);
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext to clarify context scope
        return AlertDialog(
          title: Text('Reset Email Sent'),
          content: Text(
              'If your email is correct, you will receive a link to reset your password.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Close the dialog with dialogContext

                // After the dialog is closed, navigate to the login screen
                // It's important to use the main BuildContext, not dialogContext here
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF5D427A),
              Color(0xFF341359),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'Reset Password',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 28,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.email, color: Colors.grey),
                          label: Text(
                            'Enter your email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          )),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _resetPassword,
                      child: Container(
                        height: 55,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(colors: [
                            Color(0xFF5D427A),
                            Color(0xFF341359),
                          ]),
                        ),
                        child: const Center(
                          child: Text(
                            'SEND RESET LINK',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
