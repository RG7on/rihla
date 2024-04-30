import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rihla/reg_screen.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF341359), // Start color of the gradient
              Color(0xFF5D427A), // End color of the gradient
            ],
            begin: Alignment.topCenter, // Gradient starts at the top
            end: Alignment.bottomCenter, // and ends at the bottom
          ),
        ),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Image(
              image: AssetImage('assets/logo.png'),
              height: 202,
              width: 202,
            ),
          ),
          Text(
            'RIHLA',
            style: GoogleFonts.inknutAntiqua(
              textStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), fontSize: 48),
            ),
          ),
          const SizedBox(
            height: 80,
          ),
          Text(
            'Welcome Back',
            style: GoogleFonts.robotoCondensed(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: Container(
              height: 57,
              width: 305,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: Center(
                child: Text(
                  'SIGN IN',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 28,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RegScreen()));
            },
            child: Container(
              height: 57,
              width: 305,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: Center(
                child: Text(
                  'SIGN UP',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 28,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          GestureDetector(
            onTap: () {
              // Handle Apple icon tap
              print('continue a guest');
            },
            child: Text(
              'continue a guest',
              style: GoogleFonts.robotoCondensed(
                fontSize: 24,
                color: const Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 45,
          ),
          Text(
            'Login with',
            style: GoogleFonts.robotoCondensed(
              fontSize: 24,
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w100,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Handle Apple icon tap
                  print('Apple tapped');
                },
                child: const Icon(Icons.apple, size: 45, color: Colors.white),
              ),
              const SizedBox(width: 30),
              GestureDetector(
                onTap: () {
                  // Handle Facebook icon tap
                  print('Facebook tapped');
                },
                child:
                    const Icon(Icons.facebook, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 30),
              GestureDetector(
                onTap: () {
                  // Handle Google icon tap
                  print('Google tapped');
                },
                // Using FontAwesomeIcons.google
                child: const Icon(FontAwesomeIcons.google,
                    size: 35, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
