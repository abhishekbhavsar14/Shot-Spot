import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoe_spot/admin_panel.dart';
import 'package:shoe_spot/dumy.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  Color common = Color(0xFF639BF6);
  bool flag = true;
  bool progress = false;
  File? image;
  showAlertDialog(){
    return showDialog(context: context, builder: (context) =>
      AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Camera',style:
              GoogleFonts.abel(fontSize: 19, fontWeight: FontWeight.w600,color: Colors.black),),
              onTap: () {
                pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Gallery',style:
              GoogleFonts.abel(fontSize: 19, fontWeight: FontWeight.w600,color: Colors.black),),
              onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
              },
            ),
          ],
        ),
      ),);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: showAlertDialog,
                child: image!= null?CircleAvatar(
                  backgroundImage: FileImage(image!),
                  radius: 50,
                ):CircleAvatar(
                  backgroundColor: common,
                  child: Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                  radius: 50,
                ),
              ),
              SizedBox(
                height: 14,
              ),
              TextField(
                controller: name,
                style:
                    GoogleFonts.abel(fontSize: 17, fontWeight: FontWeight.w600),
                cursorHeight: 16,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Enter name',
                    hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(
                height: 14,
              ),
              TextField(
                controller: email,
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
              SizedBox(
                height: 14,
              ),
              TextField(
                controller: password,
                style:
                    GoogleFonts.abel(fontSize: 17, fontWeight: FontWeight.w600),
                cursorColor: Colors.black,
                cursorHeight: 16,
                obscureText: flag,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Enter password',
                    hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            flag = !flag;
                          });
                        },
                        icon: Icon(
                            flag ? Icons.visibility_off : Icons.visibility))),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: common),
                  child: progress ? CircularProgressIndicator(color: Colors.white,):Text(
                    'Sign Up',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                onTap: () {
                  setState(() {
                    progress = true;
                  });
                  print('Current User is : ${FirebaseAuth.instance.currentUser}');
                  if (name.text.toString().isNotEmpty &&
                      email.text.toString().isNotEmpty &&
                      password.text.toString().isNotEmpty) {
                    addUser(
                        name.text.toString().trim(),
                        email.text.toString().trim(),
                        password.text.toString().trim());
                  } else {
                    Fluttertoast.showToast(msg: 'Please fill the fields',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
                  }
                },
              ),
              SizedBox(
                height: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addUser(String name, String email, String password) async{
    try{
      String? url;
      Map<String,dynamic> map;
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)
      .then((onValue) async {
        setState(() {
            progress = false;
        });
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomePageScreen(),));
        if(image!=null){
          UploadTask task = FirebaseStorage.instance.ref('Images').child(name).putFile(image!);
          TaskSnapshot snapshot = await task;
          url = await snapshot.ref.getDownloadURL();
          map = {
            'firstName':name,
            'email':email,
            'image':url
            // 'uid':uid
          };
          if(url!=null){
            print('Ok no null');
          }else{
            print('Null');
          }
        }
        map = {
          'firstName':name,
          'email':email,
          // 'uid':uid
        };
        FirebaseFirestore.instance.collection('Users').doc(email).set(map).then((onValue){
          print('data added');
        }).catchError((onError){
          print('Error while adding data $onError');
        });
        return onValue;
      });
    }on FirebaseAuthException catch(e){
      setState(() {
        progress = false;
      });
      if (e.code == 'email-already-in-use') {
        // Show message using ScaffoldMessenger
        Fluttertoast.showToast(msg: 'User with this email already exists.',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      }else if(e.code == 'weak-password'){
        Fluttertoast.showToast(msg: 'Password minimum be 6 character',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
       }else if(e.code == 'invalid-email'){
        Fluttertoast.showToast(msg: 'Invalid Email Format',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      } else{
        Fluttertoast.showToast(msg: '${e.message}',backgroundColor: common,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      }
    }
  }
  void  pickImage(ImageSource source) async{
    try{
      var photo = await ImagePicker().pickImage(source: source);
      if(photo != null){
        var tempfile = File(photo.path);
        setState(() {
          image = tempfile;
        });
      }
    }catch(e){
      print(e);
    }
  }
}
