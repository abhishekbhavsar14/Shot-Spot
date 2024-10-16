import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoe_spot/sign_in_screen.dart';
import 'package:shoe_spot/sign_up_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Color common = Color(0xFF639BF6);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/userlogin.png',
                height: 160,
                width: 160,
              ),
              Text(
                'Welcome to Shoe Spot',
                style:
                    GoogleFonts.abel(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10,),
              Text(
                'Discover the perfect fit. Style, comfort, and performance for every ste!p.',
                style:
                GoogleFonts.abel(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 18,
              ),
              InkWell(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => SignUpScreen(),)),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(24),
                      ),
                      color: common),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                      border: Border.all(color: common)),
                  child: Text('Sign Up',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: common,
                          fontWeight: FontWeight.w500)),
                ),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => SignInScreen(),));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
