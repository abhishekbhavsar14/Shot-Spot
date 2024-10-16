import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var emil = TextEditingController();
    Color common = Color(0xFF639BF6);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: common,
        title: Text('Forgot Password',style: GoogleFonts.podkova(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
        iconTheme: IconThemeData(color: Colors.white)),
      body: Center(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emil,
                style:
                GoogleFonts.abel(fontSize: 17, fontWeight: FontWeight.w600),
                cursorHeight: 16,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Enter mail',
                    hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: () {
                  if(emil.text.toString().isNotEmpty){
                    try{
                      final auth = FirebaseAuth.instance;
                      auth.sendPasswordResetEmail(email: emil.text.toString());
                      Fluttertoast.showToast(msg: 'We have send link your email address',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
                    } on FirebaseAuthException catch(e){
                      Fluttertoast.showToast(msg: '${e.message}',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
                    }
                  }else{
                    Fluttertoast.showToast(msg: 'Please enter your mail',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: common),
                  child:Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
